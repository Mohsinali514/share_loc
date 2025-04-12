# new_app

A new Flutter project.

## Getting Started

Live Location Sharing App
A Flutter-based mobile application that allows users to share and track real-time locations within private circles. The app is built using clean architecture, feature-wise folder structure, and incorporates real-time data handling via Firebase and OpenStreetMap (OSM) integration.

User Authentication

Firebase Email/Password login

Role-based Circle Joining/Creation

FirebaseAuth with Firestore for user data

Circle (Group) Management

Create or join private circles

Update user roles within circles

View members of current circle (Name, Bio, Last Location)

Onboarding & Setup

Onboarding and Welcome screens

Permission requests (Location, Notifications, etc.)

Add initial default place (Home) using OSM Flutter and Geocoding

Live Location Sharing

Real-time location tracking using Firebase

Members' live locations displayed on the map

Current user’s live location excluded from member list for clarity

Map Integration

OpenStreetMap (OSM) with location markers

Geocoding for address lookup and place marking

Add, view, and delete places in the circle

Circle Home Page

Circle Management

View selected circle’s data

See members list and their last updated locations and live locations on map

Group Chat

Real-time group chat between circle members using Firebase


Setup Instructions:
Clone the Repository
git clone https://github.com/your-username/live-location-sharing.git
cd live-location-sharing

Install Dependencies:
flutter pub get

Run the App:
flutter run

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
