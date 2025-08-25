import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage.dart';
import 'privacy_policy_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _goalDaysController = TextEditingController();
  String _selectedGender = '女性';
  double _activityFactor = 1.2;
  double? _calculatedCalories;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalDaysController.dispose();
    super.dispose();
  }

  Future<void> _calculateCalories() async {
    if (_formKey.currentState!.validate()) {
      final age = int.tryParse(_ageController.text);
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);
      final goalDays = int.tryParse(_goalDaysController.text);
      final gender = _selectedGender;

      if (age == null || weight == null || height == null || goalDays == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('すべての項目を正しく入力してください')),
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

      if (goalDays <= 0 || goalDays > 3650) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目標期間は1〜3650日の範囲で入力してください')),
        );
        return;
      }

      try {
        // 基礎代謝（ハリスベネディクト方程式）
        double bmr = gender == '男性'
            ? 13.397 * weight + 4.799 * height - 5.677 * age + 88.362
            : 9.247 * weight + 3.098 * height - 4.33 * age + 447.593;

        // 総消費カロリー
        double totalCalories = bmr * _activityFactor;

        // 1日の摂取カロリー（300kcal多めに提示）
        double dailyCalories = totalCalories - (7700 * (weight - (weight - 1)) / goalDays) + 300;

        if (mounted) {
          setState(() {
            _calculatedCalories = dailyCalories;
          });
        }

        // 計算結果を保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('dailyCalories', dailyCalories);
        
        // 他の設定も保存（ホームページで使用するため）
        await prefs.setInt('age', age);
        await prefs.setDouble('currentWeight', weight);
        await prefs.setDouble('height', height);
        await prefs.setInt('goalDays', goalDays);
        await prefs.setString('gender', gender);
        await prefs.setDouble('activityFactor', _activityFactor);
        await prefs.setDouble('targetWeight', weight - 1); // 仮の目標体重
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('計算中にエラーが発生しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveAndNavigate() async {
    if (_calculatedCalories != null) {
      try {
        // 目標カロリーを保存
        await DataStorage.saveDailyTargetCalories(_calculatedCalories!);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('設定の保存に失敗しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('初期設定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_ageController, '年齢（歳）'),
              _buildTextField(_weightController, '体重（kg）'),
              _buildTextField(_heightController, '身長（cm）'),
              _buildTextField(_goalDaysController, '体重を落としたい日数（日）'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['女性', '男性']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
                decoration: const InputDecoration(labelText: '性別'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _activityFactor,
                items: const [
                  DropdownMenuItem(value: 1.2, child: Text('あまり運動しない')),
                  DropdownMenuItem(value: 1.375, child: Text('軽い運動')),
                  DropdownMenuItem(value: 1.55, child: Text('中程度の運動')),
                  DropdownMenuItem(value: 1.725, child: Text('激しい運動')),
                ],
                onChanged: (value) => setState(() => _activityFactor = value!),
                decoration: const InputDecoration(labelText: '活動係数'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateCalories,
                child: const Text('カロリー計算'),
              ),
              if (_calculatedCalories != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '計算結果',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1日の摂取カロリー目安: ${_calculatedCalories!.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('設定変更'),
                ),
              ],
              const SizedBox(height: 24),
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
                  label: const Text(
                    'プライバシーポリシー',
                    style: TextStyle(
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.isEmpty ? '入力してください' : null,
      ),
    );
  }
}
