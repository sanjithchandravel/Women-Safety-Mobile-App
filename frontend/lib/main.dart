import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Import sensors_plus

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Safety App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserSwitcher(),
    );
  }
}

class UserSwitcher extends StatefulWidget {
  @override
  _UserSwitcherState createState() => _UserSwitcherState();
}

class _UserSwitcherState extends State<UserSwitcher> {
  String? _selectedUser;
  Map<String, String> _userDetails = {};
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _startLocationTracking();
    _startGestureDetection();
  }

  Future<void> _loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users');
    Map<String, String> userDetails = {};

    if (users != null) {
      for (String user in users) {
        String? gender = prefs.getString('gender_$user');
        userDetails[user] = gender ?? 'Not specified';
      }
    }

    setState(() {
      _userDetails = userDetails;
      _selectedUser = users?.isNotEmpty == true ? users!.first : null;
    });
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied.');
      return;
    }

    _showSnackBar('Location permissions granted. Starting location tracking.');

    // Set up a periodic timer to fetch location every 1 minute
    _locationTimer = Timer.periodic(Duration(minutes: 1), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print(
            'Position received: Lat: ${position.latitude}, Lon: ${position.longitude}');
        await _sendLocationData(position);
      } catch (e) {
        _showSnackBar('Error fetching location: $e');
      }
    });

    // Log periodic location tracking start
    print('Periodic location tracking started.');
  }

  Future<void> _sendLocationData(Position position,
      {bool gestureDetected = false}) async {
    if (_selectedUser != null) {
      var locationData = {
        'user': _selectedUser,
        'gender': _userDetails[_selectedUser!],
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'gestureDetected': gestureDetected,
      };

      print('Sending location data: $locationData');

      try {
        final response = await http
            .post(
              Uri.parse('https://women-safety-1-30m6.onrender.com/location'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(locationData),
            )
            .timeout(Duration(seconds: 15)); // Adjust timeout if needed

        if (response.statusCode == 200) {
          _showSnackBar('Location data sent successfully.');
        } else {
          _showSnackBar(
              'Failed to send location data. Status code: ${response.statusCode}');
        }
      } catch (e) {
        _showSnackBar('Error sending location data: $e');
      }
    } else {
      _showSnackBar('No user selected. Location data not sent.');
    }
  }

  Future<void> _selectUser(String? name) async {
    setState(() {
      _selectedUser = name;
    });
  }

  Future<void> _addUser() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserPage(),
      ),
    ).then((_) => _loadUsers());
  }

  Future<void> _deleteUser(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? users = prefs.getStringList('users') ?? [];

    // Remove the user from the list
    users.remove(userName);
    await prefs.setStringList('users', users);

    // Remove gender information
    await prefs.remove('gender_$userName');

    // Update user details map and selected user
    setState(() {
      _userDetails.remove(userName);
      if (_selectedUser == userName) {
        _selectedUser = users.isNotEmpty ? users.first : null;
      }
    });
  }

  void _startGestureDetection() {
    const double SHAKE_THRESHOLD = 30.0; // Adjusted for better sensitivity
    const int SHAKE_TIMEOUT_MS = 300; // Shortened timeout for quicker detection
    int _lastShakeTime = 0;

    accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration =
          math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (acceleration > SHAKE_THRESHOLD) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - _lastShakeTime > SHAKE_TIMEOUT_MS) {
          _lastShakeTime = currentTime;
          _handleShake();
        }
      }
    });
  }

  Future<void> _handleShake() async {
    print('Shake detected!');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _sendLocationData(position, gestureDetected: true);
    } catch (e) {
      _showSnackBar('Error fetching location on shake: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    print('Stopping location tracking.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Women Safety App'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select User:',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.pink),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedUser,
              hint: Text('Select User'),
              items: _userDetails.keys.map((user) {
                return DropdownMenuItem<String>(
                  value: user,
                  child: Row(
                    children: [
                      Expanded(child: Text(user)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteUser(user);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _selectUser,
              isExpanded: true,
              dropdownColor: Colors.pink[50],
            ),
            SizedBox(height: 20),
            Text(
              'User Details:',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.pink),
            ),
            SizedBox(height: 10),
            if (_selectedUser != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Name: $_selectedUser\nGender: ${_userDetails[_selectedUser!]}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addUser,
              icon: Icon(Icons.person_add),
              label: Text('Add New User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _nameController = TextEditingController();
  String? _selectedGender;

  Future<void> _saveUser() async {
    if (_nameController.text.isNotEmpty && _selectedGender != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? users = prefs.getStringList('users') ?? [];
      users.add(_nameController.text);
      await prefs.setStringList('users', users);
      await prefs.setString('gender_${_nameController.text}', _selectedGender!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name and select a gender')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New User'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: Text('Select Gender'),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveUser,
              icon: Icon(Icons.save),
              label: Text('Save User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//3
