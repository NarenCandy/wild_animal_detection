// lib/services/onesignal_service.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../api/api_service.dart';

Future<void> initOneSignal() async {
  final appId = dotenv.env['ONESIGNAL_APP_ID'];
  if (appId == null || appId.isEmpty) {
    print("⚠️ OneSignal App ID not set in .env");
    return;
  }

  print("🔔 Initializing OneSignal v5...");

  // Initialize OneSignal
  OneSignal.initialize(appId);

  // Request notification permission
  bool permission = await OneSignal.Notifications.requestPermission(true);
  print("📱 Notification permission: $permission");

  // Note: Notification channels are created automatically by Android
  // when your backend sends notifications with android_channel_id
  print("✅ Notification channels will be created automatically");

  // Handle notification clicked (when user taps notification)
  OneSignal.Notifications.addClickListener((event) {
    print("🔔 Notification tapped");
    final data = event.notification.additionalData;
    if (data != null) {
      print("   Data: $data");
      // Navigate based on data
      // Example: Navigator.pushNamed(context, "/alert-details", arguments: data);
    }
  });

  // Handle notification received while app is open (foreground)
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("📨 Notification received in foreground");
    // Display the notification even when app is open
    event.notification.display();
  });

  // Get player ID (OneSignal's unique device identifier)
  String? playerId = OneSignal.User.pushSubscription.id;
  print("🆔 OneSignal Player ID: $playerId");

  // Register with backend if logged in
  if (playerId != null && playerId.isNotEmpty) {
    try {
      await ApiService.registerPlayer(playerId);
      print("✅ Player ID registered with backend");
    } catch (e) {
      print("⚠️ Failed to register player ID: $e");
    }
  } else {
    print("⚠️ No player ID yet - user may need to grant permission");
  }

  print("✅ OneSignal initialization complete");
}
