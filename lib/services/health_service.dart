import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthService {
  // 健康データ機能を一時的に無効化（リリース後に有効化予定）
  
  static Future<bool> initialize() async {
    if (kDebugMode) {
      debugPrint('Health service temporarily disabled');
    }
    return false;
  }

  static Future<List<dynamic>> getWeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('Weight data get temporarily disabled');
    }
    return [];
  }

  static Future<List<dynamic>> getHeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('Height data get temporarily disabled');
    }
    return [];
  }

  static Future<List<dynamic>> getStepsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('Steps data get temporarily disabled');
    }
    return [];
  }

  static Future<List<dynamic>> getCaloriesBurnedData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('Calories burned data get temporarily disabled');
    }
    return [];
  }

  static Future<bool> saveWeightData(double weight) async {
    if (kDebugMode) {
      debugPrint('Weight data save temporarily disabled');
    }
    return false;
  }

  static Future<double?> getLatestWeight() async {
    if (kDebugMode) {
      debugPrint('Latest weight get temporarily disabled');
    }
    return null;
  }

  static Future<int> getTodaySteps() async {
    if (kDebugMode) {
      debugPrint('Today steps get temporarily disabled');
    }
    return 0;
  }

  static Future<double> getTodayCaloriesBurned() async {
    if (kDebugMode) {
      debugPrint('Today calories burned get temporarily disabled');
    }
    return 0;
  }

  static Future<void> saveSyncSettings({
    required bool syncWeight,
    required bool syncSteps,
    required bool syncCalories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_weight', syncWeight);
    await prefs.setBool('sync_steps', syncSteps);
    await prefs.setBool('sync_calories', syncCalories);
  }

  static Future<Map<String, bool>> getSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'sync_weight': prefs.getBool('sync_weight') ?? false,
      'sync_steps': prefs.getBool('sync_steps') ?? false,
      'sync_calories': prefs.getBool('sync_calories') ?? false,
    };
  }

  static Future<void> syncHealthData() async {
    try {
      final settings = await getSyncSettings();
      
      if (settings['sync_weight'] == true) {
        final latestWeight = await getLatestWeight();
        if (latestWeight != null) {
          // アプリ内の体重データと同期
          final prefs = await SharedPreferences.getInstance();
          final today = DateTime.now().toIso8601String().split('T')[0];
          await prefs.setString('weight_$today', latestWeight.toString());
        }
      }
      
      if (settings['sync_steps'] == true) {
        final todaySteps = await getTodaySteps();
        // 歩数データをアプリ内に保存
        final prefs = await SharedPreferences.getInstance();
        final today = DateTime.now().toIso8601String().split('T')[0];
        await prefs.setInt('steps_$today', todaySteps);
      }
      
      if (settings['sync_calories'] == true) {
        final todayCalories = await getTodayCaloriesBurned();
        // 消費カロリーデータをアプリ内に保存
        final prefs = await SharedPreferences.getInstance();
        final today = DateTime.now().toIso8601String().split('T')[0];
        await prefs.setDouble('calories_burned_$today', todayCalories);
      }
      
      if (kDebugMode) {
        debugPrint('Health data sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing health data: $e');
      }
    }
  }

  static Future<List<dynamic>> getAvailableDataTypes() async {
    if (kDebugMode) {
      debugPrint('Available data types get temporarily disabled');
    }
    return [];
  }

  static Future<bool> isHealthDataAvailable() async {
    try {
      final availableTypes = await getAvailableDataTypes();
      return availableTypes.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking health data availability: $e');
      }
      return false;
    }
  }
} 