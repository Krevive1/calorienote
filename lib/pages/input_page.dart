import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての項目を入力してください')),
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
      // 完了メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('設定を変更しました'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // 少し遅延させてからホームページに戻る
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('まずカロリーを計算してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '体重目標変更',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    const Text(
                      'あなたの目標を設定しましょう',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'より正確なカロリー計算のために、以下の情報を入力してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
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
                        const Text(
                          '基本情報',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: '年齢',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: '身長 (cm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: '現在の体重 (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _targetWeightController,
                      decoration: const InputDecoration(
                        labelText: '目標体重 (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
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
                              const Text(
                                '推奨目標体重',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                                                                                Text(
                             '1か月で体重の5％（例：60㎏の場合 57㎏）推奨です',
                             style: TextStyle(
                               color: Colors.blue.shade700,
                               fontSize: 13,
                             ),
                           ),
                           const SizedBox(height: 4),
                           const Text(
                             '※過度な減量は、ホルモンバランスの乱れ、筋肉量の低下、代謝の低下を招き、リバウンドの原因となります',
                             style: TextStyle(
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
                      decoration: const InputDecoration(
                        labelText: '目標達成日数',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
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
                        const Text(
                          '詳細設定',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: '性別',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      onChanged: (value) => setState(() => _gender = value!),
                      items: const [
                        DropdownMenuItem(value: '女性', child: Text('女性')),
                        DropdownMenuItem(value: '男性', child: Text('男性')),
                      ],
                    ),
                    const SizedBox(height: 16),
                                         DropdownButtonFormField<double>(
                       value: _activityFactor,
                       decoration: const InputDecoration(
                         labelText: '普段の活動レベル',
                         border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.fitness_center),
                       ),
                       onChanged: (value) => setState(() => _activityFactor = value!),
                       items: const [
                         DropdownMenuItem(value: 1.2, child: Text('あまり運動しない')),
                         DropdownMenuItem(value: 1.55, child: Text('適度な運動をしている')),
                         DropdownMenuItem(value: 1.9, child: Text('高強度な運動をしている')),
                       ],
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 計算ボタン
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('計算中...', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      : const Text(
                          'カロリーを計算',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
                        '1日の摂取カロリー目安',
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
                                         child: const Text(
                       '設定を変更',
                       style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                     ),
                  ),
                ),
              ],
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
