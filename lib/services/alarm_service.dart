import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint("Notification clicked: ${details.payload}");
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint("Notifications init warning: $e");
    }
  }

  Future<void> scheduleDailyAlarm({
    required int hour,
    required int minute,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'smart_money_channel',
        'Daily Money Log Reminder',
        channelDescription:
            'Reminds user to record daily expenses and protect their streak',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      // Cancel previous scheduled reminders before rescheduling
      await _notificationsPlugin.cancel(101);

      await _notificationsPlugin.show(
        101,
        'SmartMoney Habit Reminder ⏰',
        "Don't lose your streak! Take 30 seconds to record today's income & expenses.",
        notificationDetails,
      );
    } catch (e) {
      debugPrint("Schedule notification warning: $e");
    }
  }

  Future<void> cancelAlarm() async {
    try {
      await _notificationsPlugin.cancel(101);
    } catch (e) {
      debugPrint("Cancel notification warning: $e");
    }
  }

  Future<void> playChimeSound() async {
    try {
      // Play a pleasant chime tone using Source URL or asset sound
      await _audioPlayer.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/cartoon/pop.ogg',
        ),
      );
    } catch (e) {
      debugPrint("Audio play warning (handled gracefully): $e");
    }
  }
}
