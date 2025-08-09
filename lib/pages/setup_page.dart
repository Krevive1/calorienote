import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _saveAndCalculate() async {
    if (_formKey.currentState!.validate()) {
      final age = int.parse(_ageController.text);
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final goalDays = int.parse(_goalDaysController.text);
      final gender = _selectedGender;

      // 基礎代謝（ハリスベネディクト方程式）
      double bmr = gender == '男性'
          ? 13.397 * weight + 4.799 * height - 5.677 * age + 88.362
          : 9.247 * weight + 3.098 * height - 4.33 * age + 447.593;

      // 総消費カロリー
      double totalCalories = bmr * _activityFactor;

      // 1日の摂取カロリー（300kcal多めに提示）
      double dailyCalories = totalCalories - (7700 * (weight - (weight - 1)) / goalDays) + 300;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('dailyCalories', dailyCalories);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
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
                onPressed: _saveAndCalculate,
                child: const Text('保存して次へ'),
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
