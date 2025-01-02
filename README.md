# flutter_core

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

If
--dart-define=API_URL=http://127.0.0.1:5000
in edit configuration next to the Stop button Top right.


You need to run in terminal: (So the app can connect to the backend docker without internet)
adb reverse tcp:5000 tcp:5000

Replace the 127.0.0.1 with the machine IP if you dont want to run the adb command.

