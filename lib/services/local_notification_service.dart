import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _plugin.initialize(settings);

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'bioimpedancia_evolucao',
        'Bioimpedância',
        channelDescription: 'Evolução de gordura, músculo e água',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(id, title, body, details);
  }
}
