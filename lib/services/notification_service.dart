import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initialize();
  }

  Future<void> _initialize() async {
    tz_init.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      print('Tidak dapat menjadwalkan notifikasi untuk waktu lampau: $title');
      return;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_notification_channel',
          'Todo Notifications',
          channelDescription: 'Notifications for todo deadlines',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleDailyReminderAt00() async {
    final now = DateTime.now();

    // Set time to next midnight (00:00)
    DateTime scheduledDate = DateTime(now.year, now.month, now.day + 1);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      'daily_reminder'.hashCode,
      'Daily Todo Reminder',
      'Check your todo list for today!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily reminders for todos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // This makes it repeat daily
    );
  }

  Future<void> scheduleDeadlineNotifications(
      String id, String title, DateTime deadline) async {
    final now = DateTime.now();

    // Calculate time differences
    final differenceInMinutes = deadline.difference(now).inMinutes;

    // Schedule notification 30 minutes before deadline if possible
    if (differenceInMinutes > 30) {
      await scheduleNotification(
        id: '$id-30min',
        title: 'Deadline Approaching',
        body: '$title is due in 30 minutes',
        scheduledDate: deadline.subtract(const Duration(minutes: 30)),
      );
    }

    // Schedule notification 1 hour before deadline if possible
    if (differenceInMinutes > 60) {
      await scheduleNotification(
        id: '$id-1hour',
        title: 'Deadline Approaching',
        body: '$title is due in 1 hour',
        scheduledDate: deadline.subtract(const Duration(hours: 1)),
      );
    }

    // Schedule notification at the deadline
    await scheduleNotification(
      id: '$id-deadline',
      title: 'Deadline Reached',
      body: '$title is due now',
      scheduledDate: deadline,
    );
  }

  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
    await _flutterLocalNotificationsPlugin.cancel('$id-30min'.hashCode);
    await _flutterLocalNotificationsPlugin.cancel('$id-1hour'.hashCode);
    await _flutterLocalNotificationsPlugin.cancel('$id-deadline'.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
