import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
      
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }
  
  static Future<void> scheduleDailyReminders() async {
    try {
      //Check permissions first
      final hasPermission = await _checkNotificationPermissions();
      if (!hasPermission) {
        print('Notification permissions not granted');
        return;
      }

      //Schedule morning glucose check
      await _scheduleDailyNotification(
        id: 0,
        title: 'Time to check your glucose!',
        body: 'Remember to log your blood sugar reading.',
        hour: 9,
        minute: 0,
      );
      
      //Schedule medication reminder
      await _scheduleDailyNotification(
        id: 1,
        title: 'Medication Reminder',
        body: 'Don\'t forget to take your medication',
        hour: 9,
        minute: 0,
      );
    
      //Schedule evening check
      await _scheduleDailyNotification(
        id: 2,
        title: 'Evening Glucose Check',
        body: 'Time for your bedtime reading',
        hour: 21,
        minute: 0,
      );
    } catch (e) {
      print('Failed to schedule notifications: $e');
    }
  }
  
  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily medication and glucose reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_alerts',
          'Instant Alerts',
          channelDescription: 'Immediate glucose alerts and reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<bool> _checkNotificationPermissions() async {
  try {
    
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestExactAlarmsPermission();
    
    //return false if null
    return result ?? false;
  } catch (e) {
    print('Notification permission check failed: $e');
    return false;
  }
}
}