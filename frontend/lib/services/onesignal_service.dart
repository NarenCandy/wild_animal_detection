import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../api/api_service.dart';

Future<void> initOneSignal() async {
  final appId = dotenv.env['ONESIGNAL_APP_ID'];
  if (appId == null) {
    print("⚠️ OneSignal App ID not set in .env");
    return;
  }
  // Replace with your OneSignal App ID from dashboard
  OneSignal.shared.setAppId(appId);

  // Optional: handle notification opened
  OneSignal.shared.setNotificationOpenedHandler((openedResult) {
    final data = openedResult.notification.additionalData;
    if (data != null) {
      print("🔔 Notification tapped with data: $data");
      // Example: Navigate to alerts page or details
      // Navigator.pushNamed(context, "/alerts");
    }
  });

  // Optional: allow showing while in foreground
  OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
    event.complete(event.notification);
  });

  // Get this device’s playerId
  final deviceState = await OneSignal.shared.getDeviceState();
  final playerId = deviceState?.userId;
  print("📱 OneSignal Player ID: $playerId");

  // Register with backend if logged in
  if (playerId != null) {
    await ApiService.registerPlayer(playerId);
  }
}
