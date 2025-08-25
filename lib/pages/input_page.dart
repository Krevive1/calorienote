import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage.dart';
import 'privacy_policy_page.dart';
import 'home_page.dart';
import '../services/locale_service.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _daysController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = '女性';
  double _activityFactor = 1.2;
  double? _recommendedCalories;
  bool _isCalculating = false;

  void _calculateCalories() async {
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final days = int.tryParse(_daysController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    if (age == null || weight == null || days == null || targetWeight == null || height == null) {
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t?.allFieldsRequired ?? 'すべての項目を入力してください')),
      );
      return;
    }

    // 入力値の範囲チェック
    if (age < 10 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('年齢は10〜120歳の範囲で入力してください')),
      );
      return;
    }

    if (weight <= 0 || weight > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('体重は1〜500kgの範囲で入力してください')),
      );
      return;
    }

    if (height <= 0 || height > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('身長は1〜300cmの範囲で入力してください')),
      );
      return;
    }

    if (targetWeight <= 0 || targetWeight > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目標体重は1〜500kgの範囲で入力してください')),
      );
      return;
    }

    if (days <= 0 || days > 3650) { // 10年以内
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目標期間は1〜3650日の範囲で入力してください')),
      );
      return;
    }

    if (weight == targetWeight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('現在の体重と目標体重が同じです')),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    // 計算処理を少し遅延させてローディング感を演出
    await Future.delayed(const Duration(milliseconds: 500));

    final bmr = _gender == '男性'
        ? 13.397 * weight + 4.799 * height - 5.677 * age + 88.362
        : 9.247 * weight + 3.098 * height - 4.330 * age + 447.593;

    final tdee = bmr * _activityFactor;
    final weightLossPerDay = (weight - targetWeight) / days;
    final calorieDeficit = weightLossPerDay * 7700;
    final recommended = tdee - calorieDeficit;

    setState(() {
      _recommendedCalories = recommended;
      _isCalculating = false;
    });

    // 目標カロリーと目標体重を保存
    await DataStorage.saveDailyTargetCalories(recommended);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('targetWeight', targetWeight);
    
    // 他の設定も保存（ホームページで使用するため）
    await prefs.setInt('age', age);
    await prefs.setDouble('currentWeight', weight);
    await prefs.setDouble('height', height);
    await prefs.setInt('goalDays', days);
    await prefs.setString('gender', _gender);
    await prefs.setDouble('activityFactor', _activityFactor);
  }

  void _completeSetup() {
    if (_recommendedCalories != null) {
      // ホーム画面で完了メッセージを表示するため、引数付きで遷移
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
            settings: RouteSettings(arguments: {
              'settingsChanged': true,
            }),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.calculateFirst ?? 'まずカロリーを計算してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.setupTitle ?? '体重目標変更',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final selected = await showModalBottomSheet<Locale?>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const Text('Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('日本語'),
                          onTap: () => Navigator.pop(ctx, const Locale('ja')),
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('English'),
                          onTap: () => Navigator.pop(ctx, const Locale('en')),
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('简体中文'),
                          onTap: () => Navigator.pop(ctx, const Locale('zh')),
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('한국어'),
                          onTap: () => Navigator.pop(ctx, const Locale('ko')),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('System default'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
              if (selected != null || selected == null) {
                AppLocale.set(selected);
                setState(() {});
              }
            },
            icon: const Icon(Icons.settings, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)?.language ?? 'language',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダーカード
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.settings, size: 40, color: Colors.lightBlue),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.setupTitle ?? 'あなたの目標を設定しましょう',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)?.setupDescription ?? 'より正確なカロリー計算のために、以下の情報を入力してください',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 基本情報カード
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.lightBlue, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.basicInfoTitle ?? '基本情報',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.ageLabel ?? '年齢',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.heightLabel ?? '身長 (cm)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.currentWeightLabel ?? '現在の体重 (kg)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _targetWeightController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.targetWeightLabel ?? '目標体重 (kg)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.blue, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)?.recommendedTargetWeightTitle ?? '推奨目標体重',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.recommendedTargetWeightDesc ?? '1か月で体重の5％（例：60㎏の場合 57㎏）推奨です',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)?.recommendedTargetWeightNote ?? '※過度な減量は、ホルモンバランスの乱れ、筋肉量の低下、代謝の低下を招き、リバウンドの原因となります',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _daysController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.goalDaysLabel ?? '目標達成日数',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 詳細設定カード
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, color: Colors.lightBlue, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.detailedSettingsTitle ?? '詳細設定',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.genderLabel ?? '性別',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.people),
                      ),
                      onChanged: (value) => setState(() => _gender = value!),
                      items: [
                        DropdownMenuItem(value: '女性', child: Text(AppLocalizations.of(context)?.genderFemale ?? '女性')),
                        DropdownMenuItem(value: '男性', child: Text(AppLocalizations.of(context)?.genderMale ?? '男性')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      value: _activityFactor,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.activityLevelLabel ?? '普段の活動レベル',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.fitness_center),
                      ),
                      onChanged: (value) => setState(() => _activityFactor = value!),
                      items: [
                        DropdownMenuItem(value: 1.2, child: Text(AppLocalizations.of(context)?.activityLevelLow ?? 'あまり運動しない')),
                        DropdownMenuItem(value: 1.55, child: Text(AppLocalizations.of(context)?.activityLevelMedium ?? '適度な運動をしている')),
                        DropdownMenuItem(value: 1.9, child: Text(AppLocalizations.of(context)?.activityLevelHigh ?? '高強度な運動をしている')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 計算ボタン
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.lightBlue, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isCalculating ? null : _calculateCalories,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isCalculating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)?.calculating ?? '計算中...', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      : Text(
                          AppLocalizations.of(context)?.calcCaloriesButton ?? 'カロリーを計算',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              if (_recommendedCalories != null) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)?.recommendedDailyCaloriesTitle ?? '1日の摂取カロリー目安',
                        style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_recommendedCalories!.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.settingsChangedButton ?? '設定を変更',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(
                    AppLocalizations.of(context)?.privacyPolicyLink ?? 'プライバシーポリシー',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _daysController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
