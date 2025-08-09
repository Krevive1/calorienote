import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // タイムゾーンデータを初期化
    tz.initializeTimeZones();

    // ローカル通知の初期化
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // 通知タップ時の処理
    debugPrint('Notification tapped: ${response.payload}');
  }



  // ローカル通知を表示
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'calorie_note_channel',
      'カロリーノート通知',
      channelDescription: '食事記録と体重管理のリマインダー',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // 食事記録リマインダーをスケジュール
  static Future<void> scheduleMealReminder({
    required TimeOfDay time,
    required List<int> days,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'meal_reminder_channel',
      '食事記録リマインダー',
      channelDescription: '食事記録のリマインダー',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    for (int day in days) {
      await _localNotifications.zonedSchedule(
        day,
        '食事記録の時間です！',
        '今日の食事内容を記録しましょう',
        _nextInstanceOfTime(time, day),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 設定を保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('meal_reminder_time', '${time.hour}:${time.minute}');
    await prefs.setStringList('meal_reminder_days', days.map((d) => d.toString()).toList());
  }

  // 体重記録リマインダーをスケジュール
  static Future<void> scheduleWeightReminder({
    required TimeOfDay time,
    required List<int> days,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weight_reminder_channel',
      '体重記録リマインダー',
      channelDescription: '体重記録のリマインダー',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    for (int day in days) {
      await _localNotifications.zonedSchedule(
        day + 100, // 食事リマインダーと重複しないようIDを調整
        '体重記録の時間です！',
        '今日の体重を記録しましょう',
        _nextInstanceOfTime(time, day),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 設定を保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight_reminder_time', '${time.hour}:${time.minute}');
    await prefs.setStringList('weight_reminder_days', days.map((d) => d.toString()).toList());
  }

  // 目標達成通知
  static Future<void> showGoalAchievementNotification({
    required String title,
    required String body,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      payload: 'goal_achievement',
    );
  }

  // 次の指定時間を計算
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    // 指定された曜日になるまで日付を進める
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // 過去の時間の場合は次の週に
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }

  // 通知設定を取得
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'meal_reminder_time': prefs.getString('meal_reminder_time') ?? '12:00',
      'meal_reminder_days': prefs.getStringList('meal_reminder_days') ?? ['1', '2', '3', '4', '5', '6', '7'],
      'weight_reminder_time': prefs.getString('weight_reminder_time') ?? '08:00',
      'weight_reminder_days': prefs.getStringList('weight_reminder_days') ?? ['1', '2', '3', '4', '5', '6', '7'],
    };
  }

  // 通知をキャンセル
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
} 