import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:calorie_note/pages/data_storage.dart';

class ShareService {
  /// 食事記録をテキスト形式で共有
  static Future<void> shareMealRecord(String date, dynamic dayData) async {
    final StringBuffer content = StringBuffer();
    
    content.writeln('📅 食事記録 - $date');
    content.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    int totalCalories = 0;
    
    // 食事記録
    if (dayData is Map<String, dynamic> && dayData['meals'] != null) {
      final meals = dayData['meals'] as List<dynamic>;
      if (meals.isNotEmpty) {
        content.writeln('\n🍽️ 食事内容:');
        for (var meal in meals) {
          final food = meal['food'] ?? meal['meal'] ?? '';
          final calories = (meal['calories'] ?? 0) as int;
          content.writeln('  • $food: +${calories}kcal');
          totalCalories += calories;
        }
      }
    } else if (dayData is List) {
      // 古い形式のデータ対応
      if (dayData.isNotEmpty) {
        content.writeln('\n🍽️ 食事内容:');
        for (var meal in dayData) {
          final food = meal['meal'] ?? '';
          final calories = (meal['calories'] ?? 0) as int;
          content.writeln('  • $food: +${calories}kcal');
          totalCalories += calories;
        }
      }
    }
    
    // 運動記録
    if (dayData is Map<String, dynamic> && dayData['exercises'] != null) {
      final exercises = dayData['exercises'] as List<dynamic>;
      if (exercises.isNotEmpty) {
        content.writeln('\n🏃‍♂️ 運動内容:');
        for (var exercise in exercises) {
          final exerciseName = exercise['exercise'] ?? '';
          final calories = (exercise['calories'] ?? 0) as int;
          content.writeln('  • $exerciseName: ${calories}kcal');
          totalCalories += calories;
        }
      }
    }
    
    // 体重記録
    if (dayData is Map<String, dynamic> && dayData['weight'] != null) {
      content.writeln('\n⚖️ 体重: ${dayData['weight']}kg');
    }
    
    content.writeln('\n📊 合計カロリー: ${totalCalories}kcal');
    content.writeln('\n📱 Calorie Note Ver2 で記録');
    
    await Share.share(content.toString(), subject: '食事記録 - $date');
  }

  /// 全期間のデータをCSV形式でエクスポート・共有
  static Future<void> shareAllDataAsCSV() async {
    try {
      final allData = await DataStorage.loadAllData();
      if (allData.isEmpty) {
        throw Exception('共有するデータがありません');
      }
      
      final StringBuffer csvContent = StringBuffer();
      
      // CSVヘッダー
      csvContent.writeln('日付,食事内容,食事カロリー,運動内容,運動カロリー,体重,合計カロリー');
      
      // データを日付順にソート
      final sortedKeys = allData.keys.toList()..sort();
      
      for (String date in sortedKeys) {
        final dayData = allData[date];
        int totalCalories = 0;
        String meals = '';
        int mealCalories = 0;
        String exercises = '';
        int exerciseCalories = 0;
        String weight = '';
        
        // 食事データの処理
        if (dayData is Map<String, dynamic> && dayData['meals'] != null) {
          final mealsList = dayData['meals'] as List<dynamic>;
          meals = mealsList.map((meal) => meal['food'] ?? meal['meal'] ?? '').join('; ');
          mealCalories = mealsList.fold<int>(0, (sum, meal) => sum + ((meal['calories'] as int?) ?? 0));
        } else if (dayData is List) {
          meals = dayData.map((meal) => meal['meal'] ?? '').join('; ');
          mealCalories = dayData.fold<int>(0, (sum, meal) => sum + ((meal['calories'] as int?) ?? 0));
        }
        
        // 運動データの処理
        if (dayData is Map<String, dynamic> && dayData['exercises'] != null) {
          final exercisesList = dayData['exercises'] as List<dynamic>;
          exercises = exercisesList.map((exercise) => exercise['exercise'] ?? '').join('; ');
          exerciseCalories = exercisesList.fold<int>(0, (sum, exercise) => sum + ((exercise['calories'] as int?) ?? 0));
        }
        
        // 体重データの処理
        if (dayData is Map<String, dynamic> && dayData['weight'] != null) {
          weight = dayData['weight'].toString();
        }
        
        totalCalories = mealCalories + exerciseCalories;
        
        // CSV行の追加（カンマを含む文字列はダブルクォートで囲む）
        csvContent.writeln('$date,"$meals",$mealCalories,"$exercises",$exerciseCalories,$weight,$totalCalories');
      }
      
      // 一時ファイルとして保存
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/calorie_record_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csvContent.toString());
      
      // ファイルを共有
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'カロリー記録データ',
        text: 'Calorie Note Ver2 の記録データです。',
      );
      
    } catch (e) {
      rethrow;
    }
  }

  /// 指定期間のデータをCSV形式でエクスポート・共有
  static Future<void> sharePeriodDataAsCSV(DateTime startDate, DateTime endDate) async {
    try {
      final allData = await DataStorage.loadAllData();
      if (allData.isEmpty) {
        throw Exception('共有するデータがありません');
      }
      
      final StringBuffer csvContent = StringBuffer();
      
      // CSVヘッダー
      csvContent.writeln('日付,食事内容,食事カロリー,運動内容,運動カロリー,体重,合計カロリー');
      
      // 指定期間のデータをフィルタリング
      final filteredData = <String, dynamic>{};
      for (String dateKey in allData.keys) {
        try {
          final date = DateTime.parse(dateKey);
          if (date.isAfter(startDate.subtract(const Duration(days: 1))) && 
              date.isBefore(endDate.add(const Duration(days: 1)))) {
            filteredData[dateKey] = allData[dateKey];
          }
        } catch (e) {
          // 日付形式でないキーはスキップ
          continue;
        }
      }
      
      if (filteredData.isEmpty) {
        throw Exception('指定期間のデータがありません');
      }
      
      // データを日付順にソート
      final sortedKeys = filteredData.keys.toList()..sort();
      
      for (String date in sortedKeys) {
        final dayData = filteredData[date];
        int totalCalories = 0;
        String meals = '';
        int mealCalories = 0;
        String exercises = '';
        int exerciseCalories = 0;
        String weight = '';
        
        // 食事データの処理
        if (dayData is Map<String, dynamic> && dayData['meals'] != null) {
          final mealsList = dayData['meals'] as List<dynamic>;
          meals = mealsList.map((meal) => meal['food'] ?? meal['meal'] ?? '').join('; ');
          mealCalories = mealsList.fold<int>(0, (sum, meal) => sum + ((meal['calories'] as int?) ?? 0));
        } else if (dayData is List) {
          meals = dayData.map((meal) => meal['meal'] ?? '').join('; ');
          mealCalories = dayData.fold<int>(0, (sum, meal) => sum + ((meal['calories'] as int?) ?? 0));
        }
        
        // 運動データの処理
        if (dayData is Map<String, dynamic> && dayData['exercises'] != null) {
          final exercisesList = dayData['exercises'] as List<dynamic>;
          exercises = exercisesList.map((exercise) => exercise['exercise'] ?? '').join('; ');
          exerciseCalories = exercisesList.fold<int>(0, (sum, exercise) => sum + ((exercise['calories'] as int?) ?? 0));
        }
        
        // 体重データの処理
        if (dayData is Map<String, dynamic> && dayData['weight'] != null) {
          weight = dayData['weight'].toString();
        }
        
        totalCalories = mealCalories + exerciseCalories;
        
        // CSV行の追加
        csvContent.writeln('$date,"$meals",$mealCalories,"$exercises",$exerciseCalories,$weight,$totalCalories');
      }
      
      // 一時ファイルとして保存
      final directory = await getTemporaryDirectory();
      final startDateStr = '${startDate.year}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}${endDate.month.toString().padLeft(2, '0')}${endDate.day.toString().padLeft(2, '0')}';
      final file = File('${directory.path}/calorie_record_${startDateStr}_${endDateStr}.csv');
      await file.writeAsString(csvContent.toString());
      
      // ファイルを共有
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'カロリー記録データ (${startDateStr}〜${endDateStr})',
        text: 'Calorie Note Ver2 の記録データです。',
      );
      
    } catch (e) {
      rethrow;
    }
  }

  /// アプリの紹介文を共有
  static Future<void> shareApp() async {
    const String appDescription = '''
📱 Calorie Note Ver2

簡単で使いやすいカロリー管理アプリ！

✨ 主な機能:
• 食事内容とカロリーの記録
• 運動による消費カロリーの記録
• 体重の記録とグラフ表示
• 過去の記録の確認
• 目標カロリーの設定

健康的な生活をサポートします！
''';

    await Share.share(appDescription, subject: 'Calorie Note Ver2 - カロリー管理アプリ');
  }
}
