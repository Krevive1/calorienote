import 'package:flutter/material.dart';
// import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthService {
  // static final HealthFactory _health = HealthFactory();

  // 健康データの種類
  // static const List<HealthDataType> _dataTypes = [
  //   HealthDataType.WEIGHT,
  //   HealthDataType.HEIGHT,
  //   HealthDataType.STEPS,
  //   HealthDataType.ACTIVE_ENERGY_BURNED,
  //   HealthDataType.BASAL_ENERGY_BURNED,
  // ];

  // 初期化と権限取得
  static Future<bool> initialize() async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Health service temporarily disabled');
      return false;
    } catch (e) {
      debugPrint('Health service initialization error: $e');
      return false;
    }
  }

  // 体重データを取得
  static Future<List<dynamic>> getWeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Weight data get temporarily disabled');
      return [];
    } catch (e) {
      debugPrint('Error getting weight data: $e');
      return [];
    }
  }

  // 身長データを取得
  static Future<List<dynamic>> getHeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Height data get temporarily disabled');
      return [];
    } catch (e) {
      debugPrint('Error getting height data: $e');
      return [];
    }
  }

  // 歩数データを取得
  static Future<List<dynamic>> getStepsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Steps data get temporarily disabled');
      return [];
    } catch (e) {
      debugPrint('Error getting steps data: $e');
      return [];
    }
  }

  // 消費カロリーデータを取得
  static Future<List<dynamic>> getCaloriesBurnedData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Calories burned data get temporarily disabled');
      return [];
    } catch (e) {
      debugPrint('Error getting calories burned data: $e');
      return [];
    }
  }

  // 体重データを健康アプリに保存
  static Future<bool> saveWeightData(double weight) async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Weight data save temporarily disabled');
      return false;
    } catch (e) {
      debugPrint('Error saving weight data: $e');
      return false;
    }
  }

  // 最新の体重を取得
  static Future<double?> getLatestWeight() async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Latest weight get temporarily disabled');
      return null;
    } catch (e) {
      debugPrint('Error getting latest weight: $e');
      return null;
    }
  }

  // 今日の歩数を取得
  static Future<int> getTodaySteps() async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Today steps get temporarily disabled');
      return 0;
    } catch (e) {
      debugPrint('Error getting today steps: $e');
      return 0;
    }
  }

  // 今日の消費カロリーを取得
  static Future<double> getTodayCaloriesBurned() async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Today calories burned get temporarily disabled');
      return 0;
    } catch (e) {
      debugPrint('Error getting today calories burned: $e');
      return 0;
    }
  }

  // 健康データの同期設定を保存
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

  // 健康データの同期設定を取得
  static Future<Map<String, bool>> getSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'sync_weight': prefs.getBool('sync_weight') ?? false,
      'sync_steps': prefs.getBool('sync_steps') ?? false,
      'sync_calories': prefs.getBool('sync_calories') ?? false,
    };
  }

  // 健康データを自動同期
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
      
      debugPrint('Health data sync completed');
    } catch (e) {
      debugPrint('Error syncing health data: $e');
    }
  }

  // 利用可能な健康データの種類を取得
  static Future<List<dynamic>> getAvailableDataTypes() async {
    try {
      // 一時的に健康データ機能を無効化
      debugPrint('Available data types get temporarily disabled');
      return [];
    } catch (e) {
      debugPrint('Error getting available data types: $e');
      return [];
    }
  }

  // デバイスが健康データをサポートしているかチェック
  static Future<bool> isHealthDataAvailable() async {
    try {
      final availableTypes = await getAvailableDataTypes();
      return availableTypes.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking health data availability: $e');
      return false;
    }
  }
} 