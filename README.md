# Women Safety Mobile App

## Overview

This mobile application enhances women's safety by providing real-time alerts, SOS functionalities, and crowdsourced reporting in areas lacking surveillance. It empowers users to quickly report unsafe situations and request assistance, fostering a safer community environment.

## Problem Statement

**Background:** With growing concerns about women’s safety and increasing crimes in various cities, there is a need for advanced surveillance and analytical solutions to protect women from potential threats. To address these issues, this project aims to provide a promising approach through real-time threat detection.

**Detailed Description:** Leveraging advanced analytics and real-time monitoring, the Women Safety Analytics solution is designed to create safer environments for women and support law enforcement in crime prevention. The proactive approach of detecting anomalies and generating alerts can significantly enhance public safety. The software continuously monitors and analyzes the environment, counting the number of men and women present, providing insights into gender distribution in specific locations, and identifying unusual patterns—such as a lone woman at night or unusual gestures—that could indicate a potential threat.

**Advantages of the System:**

- Real-time monitoring and alerts help create a safer environment.
- Early detection enables law enforcement to intervene before situations escalate.
- Continuous analysis provides valuable data to identify hotspots and trends, supporting strategic planning for city safety.

**Expected Solution:** The Women Safety Analytics app includes functionalities for:

1. Person detection and gender classification.
2. Gender distribution analysis: Counting the number of men and women present in the scene.
3. Identifying a lone woman at night.
4. Detecting if a woman is surrounded by men.
5. Recognizing SOS situations through gesture analytics.
6. Identifying hotspots where incidents are more likely to occur based on past alerts.

## Features

1. **SOS Functionality**
    - Quickly sends an SOS alert to emergency contacts or authorities.
    - Utilizes GPS for real-time location tracking, enabling responders to locate the user efficiently.
2. **Automatic Alerts**
    - Detects distress signals based on specific gestures or rapid phone movements.
    - Sends automatic alerts in emergencies, ensuring prompt responses.
3. **Crowdsourced Reporting**
    - Users can report suspicious activities or unsafe areas, contributing to a shared safety database.
    - Data helps identify hotspots and supports city officials in proactive safety planning.
4. **Real-Time Notifications**
    - Sends alerts when users enter high-risk areas based on crowd-sourced and historical data.
    - Increases user awareness of potential dangers in specific locations.

## Technical Stack

- **Frontend**: Built with Flutter for a cross-platform, responsive mobile experience.
- **Backend**: JavaScript server linked to MongoDB Atlas for location data storage and real-time updates.
- **Data Storage**: MongoDB Atlas, which manages location and analytics data efficiently.

## API

The app connects to the backend via a designated URL. The backend API stores and updates the user’s location data in MongoDB Atlas, enabling real-time analysis and supporting the app's safety features.
