import 'dart:math';
import 'package:calorie_note/pages/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class DummyDataService {
  static final Random _random = Random();
  
  // 食事のダミーデータ
  static final List<Map<String, dynamic>> _mealExamples = [
    {'name': '朝食セット', 'calories': 450},
    {'name': '昼食セット', 'calories': 650},
    {'name': '夕食セット', 'calories': 550},
    {'name': 'サラダ', 'calories': 120},
    {'name': 'スープ', 'calories': 80},
    {'name': 'パスタ', 'calories': 400},
    {'name': 'カレー', 'calories': 500},
    {'name': '焼き魚', 'calories': 200},
    {'name': '野菜炒め', 'calories': 150},
    {'name': '味噌汁', 'calories': 60},
    {'name': 'ご飯', 'calories': 200},
    {'name': '納豆', 'calories': 100},
    {'name': '卵焼き', 'calories': 120},
    {'name': '焼肉', 'calories': 350},
    {'name': '天ぷら', 'calories': 300},
    {'name': '寿司', 'calories': 250},
    {'name': 'ラーメン', 'calories': 600},
    {'name': 'うどん', 'calories': 350},
    {'name': 'そば', 'calories': 300},
    {'name': 'おにぎり', 'calories': 180},
  ];

  // 運動のダミーデータ
  static final List<Map<String, dynamic>> _exerciseExamples = [
    {'name': 'ウォーキング', 'calories': 150},
    {'name': 'ジョギング', 'calories': 300},
    {'name': 'ランニング', 'calories': 400},
    {'name': 'サイクリング', 'calories': 250},
    {'name': '水泳', 'calories': 350},
    {'name': '筋トレ', 'calories': 200},
    {'name': 'ヨガ', 'calories': 120},
    {'name': 'ストレッチ', 'calories': 80},
    {'name': 'ダンス', 'calories': 280},
    {'name': 'テニス', 'calories': 320},
    {'name': 'バスケットボール', 'calories': 400},
    {'name': 'サッカー', 'calories': 350},
    {'name': '卓球', 'calories': 180},
    {'name': 'ゴルフ', 'calories': 200},
    {'name': '登山', 'calories': 450},
  ];

  // 1週間分のダミーデータを生成
  static Future<void> generateWeekData() async {
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      await _generateDayData(date);
    }
  }

  // 1日分のダミーデータを生成
  static Future<void> _generateDayData(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    
    // 体重データ（ランダムな変動）
    final baseWeight = 65.0;
    final weightVariation = (_random.nextDouble() - 0.5) * 2.0; // ±1kg
    final weight = baseWeight + weightVariation;
    await DataStorage.saveWeight(dateString, weight);

    // 食事データ（1日2-4回）
    final mealCount = _random.nextInt(3) + 2; // 2-4回
    final List<Map<String, dynamic>> meals = [];
    for (int i = 0; i < mealCount; i++) {
      final meal = _mealExamples[_random.nextInt(_mealExamples.length)];
      final mealVariation = (_random.nextDouble() - 0.5) * 0.4 + 1.0; // ±20%
      final calories = (meal['calories'] * mealVariation).round();
      
      meals.add({
        'meal': meal['name'],
        'calories': calories,
      });
    }

    // 運動データ（1日0-2回）
    final exerciseCount = _random.nextInt(3); // 0-2回
    final List<Map<String, dynamic>> exercises = [];
    for (int i = 0; i < exerciseCount; i++) {
      final exercise = _exerciseExamples[_random.nextInt(_exerciseExamples.length)];
      final exerciseVariation = (_random.nextDouble() - 0.5) * 0.3 + 1.0; // ±15%
      final calories = (exercise['calories'] * exerciseVariation).round();
      
      exercises.add({
        'exercise': exercise['name'],
        'calories': calories,
      });
    }

    // 1日分のデータをまとめて保存
    await DataStorage.saveDaySummary(dateString, meals: meals, exercises: exercises);
  }

  // 指定した日数分のダミーデータを生成
  static Future<void> generateDataForDays(int days) async {
    final now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      await _generateDayData(date);
    }
  }

  // 既存データをクリアしてからダミーデータを生成
  static Future<void> clearAndGenerateWeekData() async {
    await DataStorage.clearAllData();
    await generateWeekData();
  }

  // ランダムな体重を生成（指定範囲内）
  static double generateRandomWeight(double minWeight, double maxWeight) {
    return minWeight + _random.nextDouble() * (maxWeight - minWeight);
  }

  // ランダムなカロリーを生成（指定範囲内）
  static int generateRandomCalories(int minCalories, int maxCalories) {
    return minCalories + _random.nextInt(maxCalories - minCalories + 1);
  }
}
