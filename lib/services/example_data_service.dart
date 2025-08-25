import 'package:flutter/material.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class ExampleDataService {
  static List<Map<String, dynamic>> getMealExamples(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
      {'name': t?.mealExampleChicken ?? '鶏むね肉皮なし100g', 'calories': 165},
      {'name': t?.mealExampleRice ?? '白米1杯', 'calories': 252},
      {'name': t?.mealExampleNatto ?? '納豆1パック', 'calories': 100},
      {'name': t?.mealExampleEgg ?? '卵1個', 'calories': 80},
      {'name': t?.mealExampleMilk ?? '牛乳200ml', 'calories': 134},
      {'name': t?.mealExampleBanana ?? 'バナナ1本', 'calories': 86},
      {'name': t?.mealExampleApple ?? 'りんご1個', 'calories': 54},
      {'name': t?.mealExampleYogurt ?? 'ヨーグルト100g', 'calories': 62},
      {'name': t?.mealExampleSalad ?? 'サラダ（レタス、トマト）', 'calories': 30},
      {'name': t?.mealExampleMisoSoup ?? '味噌汁1杯', 'calories': 50},
      {'name': t?.mealExampleGrilledFish ?? '焼き魚1切れ', 'calories': 120},
      {'name': t?.mealExampleTofu ?? '豆腐1/2丁', 'calories': 72},
      {'name': t?.mealExampleBrownRice ?? '玄米1杯', 'calories': 218},
      {'name': t?.mealExampleSweetPotato ?? 'サツマイモ1個', 'calories': 140},
    ];
  }

  static List<Map<String, dynamic>> getExerciseExamples(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
      {'name': t?.exerciseExampleWalking ?? 'ウォーキング20分', 'calories': -80},
      {'name': t?.exerciseExampleJogging ?? 'ジョギング10分', 'calories': -100},
      {'name': t?.exerciseExampleStrengthTraining ?? '筋トレ20分', 'calories': -120},
      {'name': t?.exerciseExampleSwimming ?? '水泳30分', 'calories': -200},
      {'name': t?.exerciseExampleCycling ?? '自転車30分', 'calories': -150},
      {'name': t?.exerciseExampleYoga ?? 'ヨガ30分', 'calories': -90},
      {'name': t?.exerciseExampleStretching ?? 'ストレッチ15分', 'calories': -30},
      {'name': t?.exerciseExampleDancing ?? 'ダンス30分', 'calories': -180},
      {'name': t?.exerciseExampleStairs ?? '階段上り10分', 'calories': -70},
      {'name': t?.exerciseExampleRunning ?? 'ランニング15分', 'calories': -150},
    ];
  }
}
