import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings = InitializationSettings(
      android: android,
    );

    await notifications.initialize(settings: settings);

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Schedule medicine reminder
  static Future<void> scheduleMedicineReminder(
    int id,
    String medicine,
    String dosage,
    DateTime time,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminder',
          channelDescription: 'MedOC medicine reminder',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notifications.zonedSchedule(
      id: id,
      title: 'MedOC Medicine Reminder',
      body: 'Take $medicine ($dosage)',
      scheduledDate: tz.TZDateTime.from(time, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // Repeat every day at the selected time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel medicine reminder
  static Future<void> cancelMedicineReminder(int id) async {
    await notifications.cancel(id: id);
  }
}
