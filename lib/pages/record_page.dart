import 'package:flutter/material.dart';
import 'package:calorie_note/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'data_storage.dart';
import '../services/health_service.dart';
import '../services/example_data_service.dart';
import 'package:flutter/foundation.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  RecordPageState createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  final _foodController = TextEditingController();
  final _calorieController = TextEditingController();
  final _weightController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _exerciseCalorieController = TextEditingController();
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _exerciseRecords = [];
  double? _targetCalories;
  double _totalCalories = 0;
  double _totalExerciseCalories = 0;
  double? _todayWeight;
  String? _selectedFoodExample;
  String? _selectedExerciseExample;
  bool _isCompleted = false;

  // 参考例のリスト（動的に取得）
  List<Map<String, dynamic>> get _foodExamples => ExampleDataService.getMealExamples(context);
  List<Map<String, dynamic>> get _exerciseExamples => ExampleDataService.getExerciseExamples(context);

  @override
  void initState() {
    super.initState();
    _loadData();
    _autoRollOverIfNeeded();
  }

  Future<String> _currentDayKey() async {
    // 将来的な「一日の開始時刻」対応を見据え、関数化
    return DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _autoRollOverIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final nowKey = await _currentDayKey();
    final lastKey = prefs.getString('last_active_day');
    if (lastKey == null) {
      await prefs.setString('last_active_day', nowKey);
      return;
    }
    if (lastKey != nowKey) {
      // 前日のデータを履歴へ保存
      final lastMeals = await DataStorage.loadMeals(lastKey);
      final lastExercises = await _loadExerciseRecordsForDate(lastKey);

      if (lastMeals.isNotEmpty || lastExercises.isNotEmpty) {
        await DataStorage.saveDaySummary(lastKey, meals: lastMeals, exercises: lastExercises);
      }

      // 今日を last_active_day として保存
      await prefs.setString('last_active_day', nowKey);

      if (mounted) {
        setState(() {
          _records = [];
          _exerciseRecords = [];
          _isCompleted = false; // 新しい日なので未完了
          _calculateTotalCalories();
          _calculateTotalExerciseCalories();
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadExerciseRecordsForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseRecordsString = prefs.getString('exercise_records');
    if (exerciseRecordsString != null) {
      final allExercises = List<Map<String, dynamic>>.from(
        jsonDecode(exerciseRecordsString).map((x) => Map<String, dynamic>.from(x))
      );
      return allExercises.where((r) => r['date'] == date).map((r) => {
        'exercise': r['exercise'],
        'calories': (r['calorie'] as num?)?.toInt() ?? 0,
      }).toList();
    }
    return [];
  }

  Future<void> _loadData() async {
    await _loadRecords();
    await _loadExerciseRecords();
    await _loadTargetCalories();
    await _loadTodayWeight();
    await _checkTodayCompletion();
  }

  Future<void> _loadRecords() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final meals = await DataStorage.loadMeals(today);
    
    if (mounted) {
      setState(() {
        _records = meals.map((meal) => {
          'food': meal['food'] ?? meal['meal'] ?? '',
          'calorie': (meal['calories'] as num?)?.toDouble() ?? 0.0,
          'date': today,
        }).toList();
        _calculateTotalCalories();
      });
    }
  }

  Future<void> _loadExerciseRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseRecordsString = prefs.getString('exercise_records');
    if (exerciseRecordsString != null && mounted) {
      setState(() {
        _exerciseRecords = List<Map<String, dynamic>>.from(
          jsonDecode(exerciseRecordsString).map((x) => Map<String, dynamic>.from(x))
        );
        _calculateTotalExerciseCalories();
      });
    }
  }

  Future<void> _loadTargetCalories() async {
    final targetCalories = await DataStorage.loadDailyTargetCalories();
    if (mounted) {
      setState(() {
        _targetCalories = targetCalories;
      });
    }
  }

  Future<void> _loadTodayWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final weightString = prefs.getString('weight_$today');
    if (weightString != null && mounted) {
      setState(() {
        _todayWeight = double.tryParse(weightString);
      });
    }
  }

  Future<void> _checkTodayCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completed = prefs.getBool('completed_$today') ?? false;
    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  void _calculateTotalCalories() {
    _totalCalories = _records.fold(0.0, (sum, record) => sum + (record['calorie'] ?? 0));
  }

  void _calculateTotalExerciseCalories() {
    _totalExerciseCalories = _exerciseRecords.fold(0.0, (sum, record) => sum + (record['calorie'] ?? 0));
  }

  void _addFoodExample() {
    if (_selectedFoodExample != null) {
      final selectedExample = _foodExamples.firstWhere(
        (example) => example['name'] == _selectedFoodExample,
      );
      _foodController.text = selectedExample['name'];
      _calorieController.text = selectedExample['calories'].toString();
      setState(() {
        _selectedFoodExample = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.snackMealExampleRequired ?? '食事参考例を選択してください')),
      );
    }
  }

  void _addExerciseExample() {
    if (_selectedExerciseExample != null) {
      final selectedExample = _exerciseExamples.firstWhere(
        (example) => example['name'] == _selectedExerciseExample,
      );
      // 手動入力欄に反映
      _exerciseController.text = selectedExample['name'];
      _exerciseCalorieController.text = selectedExample['calories'].abs().toString();
      setState(() {
        _selectedExerciseExample = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.snackExerciseExampleRequired ?? '運動参考例を選択してください')),
      );
    }
  }

  Future<void> _saveExerciseRecord(String exercise, double calories) async {
    final prefs = await SharedPreferences.getInstance();
    final date = DateTime.now().toIso8601String().split('T')[0];

    final record = {'exercise': exercise, 'calorie': calories, 'date': date};
    _exerciseRecords.add(record);

    await prefs.setString('exercise_records', jsonEncode(_exerciseRecords));

    setState(() {
      _calculateTotalExerciseCalories();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context)?.exerciseRecordedMessage ?? '運動を記録しました！'}(${calories.abs()}${AppLocalizations.of(context)?.unitKcal ?? 'kcal'}${AppLocalizations.of(context)?.burnedCaloriesLabel ?? '消費'})')),
      );
    }
  }

  Future<void> _saveManualExercise() async {
    // キーボードを閉じる
    FocusScope.of(context).unfocus();
    
    final exercise = _exerciseController.text.trim();
    final calories = double.tryParse(_exerciseCalorieController.text) ?? 0;

    if (exercise.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('運動名を入力してください')),
        );
      }
      return;
    }

    if (calories <= 0 || calories > 5000) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('消費カロリーは1〜5000の範囲で入力してください')),
        );
      }
      return;
    }

    try {
      // 消費カロリーは負の値として保存
      await _saveExerciseRecord(exercise, -calories.abs());

      _exerciseController.clear();
      _exerciseCalorieController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _saveWeight() async {
    // キーボードを閉じる
    FocusScope.of(context).unfocus();
    
    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('体重を入力してください')),
        );
      }
      return;
    }

    if (weight <= 0 || weight > 500) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('体重は1〜500kgの範囲で入力してください')),
        );
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('weight_$today', weight.toString());
      setState(() {
        _todayWeight = weight;
      });
      _weightController.clear();
      
      // 健康アプリに体重データを同期
      try {
        await HealthService.saveWeightData(weight);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to sync weight to health app: $e');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.snackWeightLogged ?? '体重を記録しました！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _saveRecord() async {
    // キーボードを閉じる
    FocusScope.of(context).unfocus();
    
    final food = _foodController.text.trim();
    final cal = double.tryParse(_calorieController.text) ?? 0;
    final date = DateTime.now().toIso8601String().split('T')[0];

    if (food.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('食事内容を入力してください')),
        );
      }
      return;
    }

    if (cal <= 0 || cal > 10000) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カロリーは1〜10000の範囲で入力してください')),
        );
      }
      return;
    }

    try {
      // DataStorageを使用して食事を保存
      await DataStorage.saveMeal(date, food, cal.toInt());

      // ローカルの記録リストにも追加（表示用）
      final record = {'food': food, 'calorie': cal, 'date': date};
      _records.add(record);

      _foodController.clear();
      _calorieController.clear();
      setState(() {
        _calculateTotalCalories();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.mealRecordedMessage ?? '食事を記録しました！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _deleteFoodRecord(int index) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await DataStorage.deleteMeal(today, index);
    
    // ローカルの記録リストからも削除
    _records.removeAt(index);
    setState(() {
      _calculateTotalCalories();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.snackMealDeleted ?? '食事記録を削除しました')),
      );
    }
  }

  Future<void> _deleteExerciseRecord(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _exerciseRecords.removeAt(index);
    await prefs.setString('exercise_records', jsonEncode(_exerciseRecords));
    setState(() {
      _calculateTotalExerciseCalories();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.snackExerciseDeleted ?? '運動記録を削除しました')),
      );
    }
  }

  void _editFoodRecord(int index) {
    final record = _records[index];
    _foodController.text = record['food'] ?? '';
    _calorieController.text = record['calorie'].toString();
    _showEditFoodDialog(index);
  }

  void _editExerciseRecord(int index) {
    final record = _exerciseRecords[index];
    _exerciseController.text = record['exercise'] ?? '';
    _exerciseCalorieController.text = record['calorie'].abs().toString();
    _showEditExerciseDialog(index);
  }

  void _showEditFoodDialog(int index) {
    final record = _records[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.edit_food_record_title ?? '食事記録を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.mealContentLabel ?? '食事内容'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _calorieController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.caloriesLabel ?? 'カロリー (kcal)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel_button_label ?? 'キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              // キーボードを閉じる
              FocusScope.of(context).unfocus();
              
              final food = _foodController.text;
              final cal = double.tryParse(_calorieController.text) ?? 0;
              
              if (food.isEmpty || cal == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)?.snackMealInputRequired ?? '食事内容とカロリーを入力してください')),
                );
                return;
              }

              final today = DateTime.now().toIso8601String().split('T')[0];
              await DataStorage.updateMeal(today, index, food, cal.toInt());
              
              // ローカルの記録リストも更新
              _records[index] = {'food': food, 'calorie': cal, 'date': today};
              
              setState(() {
                _calculateTotalCalories();
              });
              
              _foodController.clear();
              _calorieController.clear();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)?.snackMealUpdated ?? '食事記録を更新しました')),
                );
              }
            },
            child: Text(AppLocalizations.of(context)?.update_button_label ?? '更新'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(int index) {
    final record = _exerciseRecords[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.edit_exercise_record_title ?? '運動記録を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _exerciseController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.exerciseNameLabel ?? '運動名'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _exerciseCalorieController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.burnedCaloriesLabel ?? '消費カロリー (kcal)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel_button_label ?? 'キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              // キーボードを閉じる
              FocusScope.of(context).unfocus();
              
              final exercise = _exerciseController.text;
              final calories = double.tryParse(_exerciseCalorieController.text) ?? 0;
              
              if (exercise.isEmpty || calories == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)?.snackExerciseInputRequired ?? '運動名と消費カロリーを入力してください')),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              _exerciseRecords[index] = {'exercise': exercise, 'calorie': -calories.abs(), 'date': record['date']};
              await prefs.setString('exercise_records', jsonEncode(_exerciseRecords));
              
              setState(() {
                _calculateTotalExerciseCalories();
              });
              
              _exerciseController.clear();
              _exerciseCalorieController.clear();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)?.snackExerciseUpdated ?? '運動記録を更新しました')),
                );
              }
            },
            child: Text(AppLocalizations.of(context)?.update_button_label ?? '更新'),
          ),
        ],
      ),
    );
  }

  double? get _remainingCalories {
    if (_targetCalories == null) return null;
    return _targetCalories! - _totalCalories - _totalExerciseCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.mealRecordTitle ?? '食事記録',
          style: const TextStyle(
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
              // 体重入力カード
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
                        const Icon(Icons.monitor_weight, color: Colors.blue, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.todayWeightTitle ?? '今日の体重',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)?.weightLabel ?? '体重 (kg)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.scale),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: _saveWeight,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          child: Text(AppLocalizations.of(context)?.record_weight_button_label ?? '記録'),
                        ),
                      ],
                    ),
                    if (_todayWeight != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${AppLocalizations.of(context)?.weightRecordedLabel ?? '記録済み'}: ${_todayWeight!.toStringAsFixed(1)} ${AppLocalizations.of(context)?.unitKg ?? 'kg'}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // カロリー状況カード
              if (_targetCalories != null)
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
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)?.calorieStatusTitle ?? 'カロリー状況',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCalorieInfo(AppLocalizations.of(context)?.targetIntakeTitle ?? '目標', _targetCalories!.toStringAsFixed(0), Colors.blue),
                          _buildCalorieInfo(AppLocalizations.of(context)?.consumedCalories ?? '摂取', _totalCalories.toStringAsFixed(0), Colors.orange),
                          _buildCalorieInfo(AppLocalizations.of(context)?.exercisesTitle ?? '運動', _totalExerciseCalories.abs().toStringAsFixed(0), Colors.green),
                          _buildCalorieInfo(AppLocalizations.of(context)?.exerciseRemainingTitle ?? '残り', _remainingCalories?.toStringAsFixed(0) ?? "0", 
                            _remainingCalories != null && _remainingCalories! >= 0 ? Colors.green : Colors.red),
                        ],
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: _targetCalories! > 0 ? ((_totalCalories + _totalExerciseCalories) / _targetCalories!).clamp(0.0, 1.0) : 0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _remainingCalories != null && _remainingCalories! >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // 運動記録カード
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
                        const Icon(Icons.fitness_center, color: Colors.green, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.exerciseRecordTitle ?? '運動記録',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                                         // 運動参考例ドロップダウン
                     DropdownButtonFormField<String>(
                       value: _selectedExerciseExample,
                       decoration: InputDecoration(
                         labelText: AppLocalizations.of(context)?.selectExampleHint ?? '運動参考例を選択',
                         border: const OutlineInputBorder(),
                         prefixIcon: const Icon(Icons.sports),
                       ),
                       hint: Text(AppLocalizations.of(context)?.select_exercise_example_hint ?? '運動参考例を選択してください'),
                       onChanged: (value) {
                         setState(() {
                           _selectedExerciseExample = value;
                         });
                       },
                       items: _exerciseExamples.map((example) {
                         return DropdownMenuItem<String>(
                           value: example['name'],
                           child: Text('${example['name']} (${example['calories'].abs()}${AppLocalizations.of(context)?.unitKcal ?? 'kcal'}${AppLocalizations.of(context)?.burnedCaloriesLabel ?? '消費'})'),
                         );
                       }).toList(),
                     ),
                     const SizedBox(height: 15),
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(
                         onPressed: _addExerciseExample,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 15),
                         ),
                         child: Text(AppLocalizations.of(context)?.add_exercise_example_button_label ?? '追加'),
                       ),
                     ),
                     const SizedBox(height: 15),
                     
                     // 手動入力欄
                     TextField(
                       controller: _exerciseController,
                       decoration: InputDecoration(
                         labelText: AppLocalizations.of(context)?.exerciseNameLabel ?? '運動名',
                         border: const OutlineInputBorder(),
                         prefixIcon: const Icon(Icons.edit),
                       ),
                     ),
                     const SizedBox(height: 15),
                     TextField(
                       controller: _exerciseCalorieController,
                       decoration: InputDecoration(
                         labelText: AppLocalizations.of(context)?.burnedCaloriesLabel ?? '消費カロリー (kcal)',
                         border: const OutlineInputBorder(),
                         prefixIcon: const Icon(Icons.local_fire_department),
                       ),
                       keyboardType: TextInputType.number,
                     ),
                     const SizedBox(height: 15),
                     
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(
                         onPressed: _saveManualExercise,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.teal,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 15),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                         ),
                         child: Text(
                           AppLocalizations.of(context)?.record_exercise_button_label ?? '運動を記録',
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                         ),
                       ),
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 食事記録カード
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
                        const Icon(Icons.restaurant, color: Colors.orange, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.mealRecordTitle ?? '食事記録',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // 参考例ドロップダウン
                    DropdownButtonFormField<String>(
                      value: _selectedFoodExample,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.selectMealExampleHint ?? '参考例を選択',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.list),
                      ),
                      hint: Text(AppLocalizations.of(context)?.select_food_example_hint ?? '参考例を選択してください'),
                      onChanged: (value) {
                        setState(() {
                          _selectedFoodExample = value;
                        });
                      },
                      items: _foodExamples.map((example) {
                        return DropdownMenuItem<String>(
                          value: example['name'],
                          child: Text('${example['name']} (${example['calories']}kcal)'),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addFoodExample,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(AppLocalizations.of(context)?.add_food_example_button_label ?? '追加'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    TextField(
                      controller: _foodController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.mealContentLabel ?? '食事内容',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _calorieController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.caloriesLabel ?? 'カロリー (kcal)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_fire_department),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.save_record_button_label ?? '記録を保存',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 今日の記録一覧
              if (_records.isNotEmpty || _exerciseRecords.isNotEmpty)
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
                          const Icon(Icons.list, color: Colors.green, size: 24),
                          const SizedBox(width: 10),
                                                  Text(
                          AppLocalizations.of(context)?.todayRecordTitle ?? '今日の記録',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // 食事記録
                      if (_records.isNotEmpty) ...[
                        Text(
                          AppLocalizations.of(context)?.mealsTitle ?? '食事',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...(_records.asMap().entries.map((entry) {
                          final index = entry.key;
                          final record = entry.value;
                          return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.orange, size: 20),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record['food'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '+${record['calorie']} kcal',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                IconButton(
                                  onPressed: () => _editFoodRecord(index),
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                ),
                                IconButton(
                                  onPressed: () => _deleteFoodRecord(index),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                      
                      // 運動記録
                      if (_exerciseRecords.isNotEmpty) ...[
                        if (_records.isNotEmpty) const SizedBox(height: 15),
                        Text(
                          AppLocalizations.of(context)?.exercisesTitle ?? '運動',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...(_exerciseRecords.asMap().entries.map((entry) {
                          final index = entry.key;
                          final record = entry.value;
                          return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.fitness_center, color: Colors.green, size: 20),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record['exercise'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${record['calorie']} kcal',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                IconButton(
                                  onPressed: () => _editExerciseRecord(index),
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                ),
                                IconButton(
                                  onPressed: () => _deleteExerciseRecord(index),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _foodController.dispose();
    _calorieController.dispose();
    _weightController.dispose();
    _exerciseController.dispose();
    _exerciseCalorieController.dispose();
    super.dispose();
  }
}

