import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {
  static Future<void> saveMeal(String date, String meal, int calories) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_$date';
    final data = prefs.getString(key);
    final List<Map<String, dynamic>> meals = data != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data))
        : [];
    meals.add({'meal': meal, 'calories': calories});
    prefs.setString(key, jsonEncode(meals));
  }

  static Future<List<Map<String, dynamic>>> loadMeals(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_$date';
    final data = prefs.getString(key);
    return data != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data))
        : [];
  }

  static Future<Map<String, dynamic>> loadAllData() async {
    // 過去記録一覧用: 日付 -> その日の保存済みデータ（旧/新形式）
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('meals_')).toList();
    final Map<String, dynamic> allData = {};

    for (var key in keys) {
      final date = key.replaceFirst('meals_', '');
      final data = prefs.getString(key);
      if (data != null) {
        allData[date] = jsonDecode(data);
      }
    }
    return allData;
  }

  static Future<Map<String, dynamic>> loadGraphData() async {
    // グラフ用: 日付 -> { weight: double?, totalCalories: double }
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final mealKeys = allKeys.where((key) => key.startsWith('meals_')).toList();
    final weightKeys = allKeys.where((key) => key.startsWith('weight_')).toList();

    final Set<String> dates = {
      ...mealKeys.map((k) => k.replaceFirst('meals_', '')),
      ...weightKeys.map((k) => k.replaceFirst('weight_', '')),
    };

    final Map<String, dynamic> allData = {};

    for (final date in dates) {
      double? weight;
      final weightString = prefs.getString('weight_$date');
      if (weightString != null) {
        weight = double.tryParse(weightString);
      }

      double totalCalories = 0;
      final mealsRaw = prefs.getString('meals_$date');
      if (mealsRaw != null) {
        final decoded = jsonDecode(mealsRaw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map && item.containsKey('calories')) {
              final num? cal = item['calories'] is num
                  ? item['calories'] as num
                  : num.tryParse(item['calories']?.toString() ?? '0');
              totalCalories += (cal?.toDouble() ?? 0);
            }
          }
        } else if (decoded is Map<String, dynamic>) {
          final meals = decoded['meals'];
          if (meals is List) {
            for (final item in meals) {
              if (item is Map && item.containsKey('calories')) {
                final num? cal = item['calories'] is num
                    ? item['calories'] as num
                    : num.tryParse(item['calories']?.toString() ?? '0');
                totalCalories += (cal?.toDouble() ?? 0);
              }
            }
          }
        }
      }

      allData[date] = {
        'weight': weight,
        'totalCalories': totalCalories,
      };
    }

    return allData;
  }

  static Future<void> saveDailyTargetCalories(double calories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('daily_target_calories', calories);
  }

  static Future<double?> loadDailyTargetCalories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('daily_target_calories');
  }

  static Future<void> savePastMeals(String date, List<Map<String, dynamic>> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_$date';
    await prefs.setString(key, jsonEncode(meals));
  }

  static Future<void> saveWeight(String date, double weight) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'weight_$date';
    await prefs.setString(key, weight.toString());
  }

  static Future<double?> loadWeight(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'weight_$date';
    final weightString = prefs.getString(key);
    return weightString != null ? double.tryParse(weightString) : null;
  }

  static Future<void> saveDaySummary(String date, {List<Map<String, dynamic>> meals = const [], List<Map<String, dynamic>> exercises = const []}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_$date';
    final existing = prefs.getString(key);

    List<Map<String, dynamic>> mergedMeals = List<Map<String, dynamic>>.from(meals);
    List<Map<String, dynamic>> mergedExercises = List<Map<String, dynamic>>.from(exercises);

    if (existing != null) {
      final decoded = jsonDecode(existing);
      if (decoded is List) {
        // 旧形式（食事のみのリスト）
        mergedMeals = [
          ...List<Map<String, dynamic>>.from(decoded),
          ...mergedMeals,
        ];
        // 旧形式には運動はないので、そのまま新しいもののみ
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['meals'] is List) {
          mergedMeals = [
            ...List<Map<String, dynamic>>.from(decoded['meals'] as List),
            ...mergedMeals,
          ];
        }
        if (decoded['exercises'] is List) {
          mergedExercises = [
            ...List<Map<String, dynamic>>.from(decoded['exercises'] as List),
            ...mergedExercises,
          ];
        }
      }
    }

    final payload = {
      'meals': mergedMeals,
      'exercises': mergedExercises,
    };
    await prefs.setString(key, jsonEncode(payload));
  }

  // 開発用: 過去7日分のダミーデータを投入
  static Future<void> seedDummyData() async {
    // final prefs = await SharedPreferences.getInstance();

    // 参考の系列（必要に応じて調整可能）
    final List<double> weights = [65.0, 64.5, 64.2, 64.0, 63.8, 63.5, 63.2];
    final List<int> totalIntakes = [1800, 1900, 1750, 1850, 1700, 1800, 1750];

    final DateTime now = DateTime.now();
    for (int offset = 6; offset >= 0; offset--) {
      final DateTime day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: offset));
      final String date = day.toIso8601String().split('T')[0];
      final int idx = 6 - offset;

      // 食事配分（朝30%, 昼50%, 夜20%）
      final int total = totalIntakes[idx];
      final int breakfast = (total * 0.3).round();
      final int lunch = (total * 0.5).round();
      final int dinner = total - breakfast - lunch;

      final meals = [
        {'meal': '朝食', 'calories': breakfast},
        {'meal': '昼食', 'calories': lunch},
        {'meal': '夕食', 'calories': dinner},
      ];

      // 運動は空（グラフは摂取推移を表示）
      final exercises = <Map<String, dynamic>>[];

      // 総括を保存（新形式）
      await saveDaySummary(date, meals: meals, exercises: exercises);

      // 体重を保存
      await saveWeight(date, weights[idx]);
    }

    // 目標カロリーの例（任意）
    await saveDailyTargetCalories(2000);
  }

  // 開発用: 31日で70→66kgの推移 + 1週間分の食事記録（減量向け）
  static Future<void> seed31DaysWeight70To66AndWeekMeals() async {
    final DateTime now = DateTime.now();

    // 体重: 70 → 66 kg（31日、30ステップ）
    const double startWeight = 70.0;
    const double endWeight = 66.0;
    const int days = 31; // inclusive
    const int steps = days - 1; // 30 intervals
    final double deltaPerDay = (endWeight - startWeight) / steps; // 約 -0.1333kg/日

    for (int i = 0; i < days; i++) {
      final DateTime day = DateTime(now.year, now.month, now.day).subtract(Duration(days: steps - i));
      final String date = day.toIso8601String().split('T')[0];
      final double weight = startWeight + deltaPerDay * i;
      await saveWeight(date, double.parse(weight.toStringAsFixed(1)));
    }

    // 食事記録（直近7日）: 目標達成のための控えめな摂取量（例: 1500〜1650kcal）
    final List<int> intakes = [1500, 1550, 1450, 1600, 1500, 1550, 1450];
    for (int offset = 6; offset >= 0; offset--) {
      final DateTime day = DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));
      final String date = day.toIso8601String().split('T')[0];
      final int total = intakes[6 - offset];

      // 配分: 朝30%, 昼45%, 夜25%
      final int breakfast = (total * 0.30).round();
      final int lunch = (total * 0.45).round();
      final int dinner = total - breakfast - lunch;

      final meals = [
        {'meal': '朝食: オートミールとヨーグルト', 'calories': breakfast},
        {'meal': '昼食: 鶏むねとサラダ・玄米', 'calories': lunch},
        {'meal': '夕食: 魚料理と野菜スープ', 'calories': dinner},
      ];

      await saveDaySummary(date, meals: meals, exercises: const []);
    }

    // 目標カロリー例
    await saveDailyTargetCalories(1800);
  }
}
