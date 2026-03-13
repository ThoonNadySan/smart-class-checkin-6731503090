# Smart Class Check-in and Learning Reflection App

## Project Description
This Flutter application helps students check in to class and submit learning reflections.

Core features:
- Class Check-in flow (GPS + QR + reflection)
- Finish Class flow (GPS + QR + post-class feedback)
- Local storage with SharedPreferences
- Firebase Firestore sync (when Firebase is configured)
- Firebase Hosting deployment for web app

## Tech Stack
- Flutter / Dart
- mobile_scanner (QR)
- geolocator (GPS)
- shared_preferences (local storage)
- firebase_core + cloud_firestore (cloud sync)
- Firebase Hosting (deployment)

## Setup Instructions
1. Install Flutter SDK
2. Run dependencies:
   flutter pub get
3. Run app (example):
   flutter run -d windows

For web:
- flutter run -d chrome

## How to Run
From project folder:
- flutter pub get
- flutter run

Build web:
- flutter build web

## Firebase Configuration Notes
This project is linked to Firebase project:
- Project ID: sccheckin-6731503090-26a

Generated file:
- lib/firebase_options.dart

Useful commands:
- firebase.cmd login
- flutterfire configure --project sccheckin-6731503090-26a --platforms=web --yes
- firebase.cmd deploy --only hosting --project sccheckin-6731503090-26a

## Firebase Deployment URL
- https://sccheckin-6731503090-26a.web.app

## Ai Usage Report

- AI Tools Used
- ChatGPT

- GitHub Copilot

- How AI Was Used
- AI tools were used to assist with several parts of the project development process.
- ChatGPT helped generate the Product Requirement Document (PRD) structure and provided guidance on how to implement features such as QR - code scanning, GPS location retrieval, and project setup.

- GitHub Copilot was used during coding in the IDE to suggest code snippets and help speed up the development of Flutter UI components and form handling.

- My Own Implementation
- I personally implemented and modified the following parts of the project:

- Flutter application structure and navigation

- Form inputs for student reflection

- Integration of QR code scanning

- GPS location retrieval

- Firebase hosting deployment

- Project setup and configuration

- The AI-generated suggestions were reviewed and adjusted to ensure they matched the project requirements.

## Notes
- On Windows/Web, QR camera scanning may be limited. The app provides manual QR input fallback.
- For full camera QR testing, use Android or iOS.


