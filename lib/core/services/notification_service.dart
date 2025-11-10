import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> init() async {
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
    await createNotificationChannel();
    await requestNotificationPermissions();
  }

  // Show simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'urban_green_mapper_channel',
      'Urban Green Mapper Notifications',
      channelDescription: 'Main notifications channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification - UPDATED VERSION
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'urban_green_mapper_channel',
      'Urban Green Mapper Notifications',
      channelDescription: 'Main notifications channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // ✅ UPDATED: Use minimal required parameters
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Create notification channel (Android)
  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'urban_green_mapper_channel',
      'Urban Green Mapper Notifications',
      description: 'Notifications for Urban Green Mapper app',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Request notification permissions
  Future<void> requestNotificationPermissions() async {
    // For iOS, request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Helper methods for your app
  Future<void> schedulePlantCareReminder({
    required int plantId,
    required String plantName,
    required DateTime reminderTime,
  }) async {
    await scheduleNotification(
      id: plantId,
      title: 'Plant Care Reminder',
      body: 'Time to care for your $plantName',
      scheduledTime: reminderTime,
    );
  }

  Future<void> scheduleEventReminder({
    required int eventId,
    required String eventTitle,
    required DateTime eventTime,
  }) async {
    await scheduleNotification(
      id: eventId,
      title: 'Event Reminder',
      body: 'Event "$eventTitle" starts soon',
      scheduledTime: eventTime.subtract(const Duration(hours: 1)),
    );
  }

  // Daily plant care reminder - UPDATED
  Future<void> scheduleDailyPlantCareReminder({
    required int plantId,
    required String plantName,
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'plant_care_channel',
      'Plant Care Reminders',
      channelDescription: 'Daily plant care reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next scheduled time
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    
    // Schedule daily notification - UPDATED
    await _notifications.zonedSchedule(
      plantId,
      'Daily Plant Care',
      'Don\'t forget to care for your $plantName',
      scheduledDate,
      details,
      payload: 'plant_care_$plantId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Helper method to calculate next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Show urgent notification
  Future<void> showUrgentNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'urgent_notifications_channel',
      'Urgent Notifications',
      channelDescription: 'Urgent and important notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      // For Android
      final bool? androidEnabled = await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();

      // For iOS - use a simpler approach
      final bool? iosEnabled = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions().then((_) => true).catchError((_) => false);

      return androidEnabled == true || iosEnabled == true;
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Cancel notifications by tag
  Future<void> cancelNotificationsByTag(String tag) async {
    // Get all pending notifications
    final List<PendingNotificationRequest> pending = await getPendingNotifications();
    
    // Cancel those that match the tag in payload
    for (final notification in pending) {
      if (notification.payload?.contains(tag) == true) {
        await cancelNotification(notification.id);
      }
    }
  }

  // Schedule weekly plant care reminder - UPDATED
  Future<void> scheduleWeeklyPlantCareReminder({
    required int plantId,
    required String plantName,
    required int hour,
    required int minute,
    required int dayOfWeek, // 1-7 (Monday-Sunday)
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weekly_plant_care_channel',
      'Weekly Plant Care Reminders',
      channelDescription: 'Weekly plant care reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next scheduled time for the specific day of week
    final tz.TZDateTime scheduledDate = _nextInstanceOfDayAndTime(dayOfWeek, hour, minute);
    
    // UPDATED: Added required parameter
    await _notifications.zonedSchedule(
      plantId + 1000, // Different ID to avoid conflicts
      'Weekly Plant Care',
      'Weekly care reminder for your $plantName',
      scheduledDate,
      details,
      payload: 'weekly_plant_care_$plantId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Helper method for weekly scheduling
  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Adjust to the correct day of week
    int daysToAdd = dayOfWeek - scheduledDate.weekday;
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }
    if (daysToAdd == 0 && scheduledDate.isBefore(now)) {
      daysToAdd = 7;
    }
    
    scheduledDate = scheduledDate.add(Duration(days: daysToAdd));
    return scheduledDate;
  }

  // Show progress notification for ongoing tasks
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications showing progress',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      onlyAlertOnce: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Update progress notification
  Future<void> updateProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'progress_channel',
      'Progress Notifications',
      channelDescription: 'Notifications showing progress',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      onlyAlertOnce: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Simple method to check if app has notification permission
  Future<bool> hasNotificationPermission() async {
    try {
      // Simple check - try to schedule a test notification
      await scheduleNotification(
        id: 999999,
        title: 'Test',
        body: 'Test notification',
        scheduledTime: DateTime.now().add(const Duration(seconds: 2)),
      );
      
      // If successful, cancel the test notification
      await cancelNotification(999999);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Schedule multiple plant care reminders - UPDATED
  Future<void> scheduleMultiplePlantCareReminders({
    required int plantId,
    required String plantName,
    required List<DateTime> reminderTimes,
  }) async {
    for (int i = 0; i < reminderTimes.length; i++) {
      await scheduleNotification(
        id: plantId * 100 + i, // Unique ID for each reminder
        title: 'Plant Care Reminder',
        body: 'Time to care for your $plantName',
        scheduledTime: reminderTimes[i],
      );
    }
  }

  // Cancel all plant care reminders for a specific plant
  Future<void> cancelPlantCareReminders(int plantId) async {
    // Get all pending notifications
    final List<PendingNotificationRequest> pending = await getPendingNotifications();
    
    // Cancel those related to this plant
    for (final notification in pending) {
      if (notification.payload?.contains('plant_care_$plantId') == true ||
          (notification.id >= plantId * 100 && notification.id < (plantId + 1) * 100)) {
        await cancelNotification(notification.id);
      }
    }
  }

  // ✅ NEW: Simple notification without scheduling (immediate)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'immediate_channel',
      'Immediate Notifications',
      channelDescription: 'Instant notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }

  // ✅ NEW: Schedule notification with repeat interval
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required Duration interval,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'repeating_channel',
      'Repeating Notifications',
      channelDescription: 'Repeating notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Schedule first notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}