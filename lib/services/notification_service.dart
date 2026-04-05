import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // List of weekly resume update notification messages
  static const List<String> _notificationMessages = [
    '📄 Time to update your resume! Add your latest achievements to stay job-ready.',
    '🚀 Don\'t miss opportunities! Update your resume with new skills or projects.',
    '🎓 Weekly Resume Check: Keep your resume updated for upcoming placements.',
    '✏️ Small updates make big impact. Review and improve your resume today.',
    '⏰ It\'s resume refresh time! Update EasyCV and stay ahead of the competition.',
  ];
  
  // List of incomplete profile notification messages
  static const List<String> _incompleteProfileMessages = [
    '👤 Your profile is incomplete. Add missing details to unlock full features.',
    '📌 Complete your profile to improve your EasyCV experience.',
    '✏️ Your profile needs a few more details. Update it now.',
    '⚠️ Profile incomplete. Please update required information.',
  ];

  // Check if platform supports notifications
  bool get isNotificationSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // Initialize notifications
  Future<void> initialize() async {
    if (!isNotificationSupported) {
      print('Notifications not supported on this platform');
      return;
    }
    
    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to profile or dashboard
    print('Notification tapped: ${response.payload}');
  }

  // Get a random unused message for weekly resume updates
  Future<String> _getRandomUnusedMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final usedIndices = prefs.getStringList('used_notification_indices') ?? [];
    
    // If all messages have been used, reset the list
    if (usedIndices.length >= _notificationMessages.length) {
      await prefs.remove('used_notification_indices');
      return _getRandomUnusedMessage();
    }

    // Get available message indices
    final availableIndices = List.generate(_notificationMessages.length, (i) => i)
        .where((i) => !usedIndices.contains(i.toString()))
        .toList();

    // Pick a random available message
    final random = Random();
    final selectedIndex = availableIndices[random.nextInt(availableIndices.length)];

    // Mark this message as used
    usedIndices.add(selectedIndex.toString());
    await prefs.setStringList('used_notification_indices', usedIndices);

    return _notificationMessages[selectedIndex];
  }
  
  // Get a random unused message for incomplete profile
  Future<String> _getRandomUnusedIncompleteProfileMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final usedIndices = prefs.getStringList('used_incomplete_profile_indices') ?? [];
    
    // If all messages have been used, reset the list
    if (usedIndices.length >= _incompleteProfileMessages.length) {
      await prefs.remove('used_incomplete_profile_indices');
      return _getRandomUnusedIncompleteProfileMessage();
    }

    // Get available message indices
    final availableIndices = List.generate(_incompleteProfileMessages.length, (i) => i)
        .where((i) => !usedIndices.contains(i.toString()))
        .toList();

    // Pick a random available message
    final random = Random();
    final selectedIndex = availableIndices[random.nextInt(availableIndices.length)];

    // Mark this message as used
    usedIndices.add(selectedIndex.toString());
    await prefs.setStringList('used_incomplete_profile_indices', usedIndices);

    return _incompleteProfileMessages[selectedIndex];
  }

  // Schedule weekly notifications
  Future<void> scheduleWeeklyNotifications() async {
    if (!isNotificationSupported) return;
    
    await cancelWeeklyNotifications(); // Cancel existing weekly notifications

    // Schedule notification for next Monday at 10:00 AM
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = _nextInstanceOfMonday(now);

    final message = await _getRandomUnusedMessage();

    const androidDetails = AndroidNotificationDetails(
      'weekly_resume_update',
      'Weekly Resume Updates',
      channelDescription: 'Reminders to update your resume weekly',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      0, // Notification ID for weekly
      'EasyCV Reminder 📝',
      message,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    print('Weekly notification scheduled for: $scheduledDate');
    print('Message: $message');
  }
  
  // Schedule daily incomplete profile notifications
  Future<void> scheduleDailyIncompleteProfileNotifications() async {
    if (!isNotificationSupported) return;
    
    await cancelIncompleteProfileNotifications(); // Cancel existing incomplete profile notifications

    // Schedule notification for daily at 9:00 AM
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = _nextInstanceOfTime(now, 9, 0); // 9:00 AM

    final message = await _getRandomUnusedIncompleteProfileMessage();

    const androidDetails = AndroidNotificationDetails(
      'incomplete_profile',
      'Profile Completion Reminders',
      channelDescription: 'Daily reminders to complete your profile',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      1, // Notification ID for incomplete profile (different from weekly)
      'Complete Your Profile 👤',
      message,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily at same time
    );

    print('Daily incomplete profile notification scheduled for: $scheduledDate');
    print('Message: $message');
  }

  // Get next Monday at 10:00 AM
  tz.TZDateTime _nextInstanceOfMonday(tz.TZDateTime now) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // 10 AM
      0,
    );

    // If today is Monday and time hasn't passed, schedule for today
    // Otherwise, find next Monday
    while (scheduledDate.weekday != DateTime.monday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
  
  // Get next instance of a specific time (for daily notifications)
  tz.TZDateTime _nextInstanceOfTime(tz.TZDateTime now, int hour, int minute) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Show immediate test notification for weekly resume update
  Future<void> showTestNotification() async {
    if (!isNotificationSupported) return;
    
    final message = await _getRandomUnusedMessage();

    const androidDetails = AndroidNotificationDetails(
      'weekly_resume_update',
      'Weekly Resume Updates',
      channelDescription: 'Reminders to update your resume weekly',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'EasyCV Reminder 📝',
      message,
      details,
    );
  }
  
  // Show immediate test notification for incomplete profile
  Future<void> showTestIncompleteProfileNotification() async {
    if (!isNotificationSupported) return;
    
    final message = await _getRandomUnusedIncompleteProfileMessage();

    const androidDetails = AndroidNotificationDetails(
      'incomplete_profile',
      'Profile Completion Reminders',
      channelDescription: 'Daily reminders to complete your profile',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000 + 1,
      'Complete Your Profile 👤',
      message,
      details,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!isNotificationSupported) return;
    await _notifications.cancelAll();
  }
  
  // Cancel only weekly notifications
  Future<void> cancelWeeklyNotifications() async {
    if (!isNotificationSupported) return;
    await _notifications.cancel(0); // ID 0 is for weekly
  }
  
  // Cancel only incomplete profile notifications
  Future<void> cancelIncompleteProfileNotifications() async {
    if (!isNotificationSupported) return;
    await _notifications.cancel(1); // ID 1 is for incomplete profile
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final result = await androidPlugin.areNotificationsEnabled();
      return result ?? false;
    }

    return true; // Assume enabled for iOS
  }

  // Reset used messages (for testing or reset functionality)
  Future<void> resetUsedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('used_notification_indices');
  }
}
