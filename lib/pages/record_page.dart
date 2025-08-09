import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'data_storage.dart';
import '../services/health_service.dart';

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

  // 参考例のリスト
  final List<Map<String, dynamic>> _foodExamples = [
    {'name': 'おにぎり1個', 'calories': 180},
    {'name': '鶏むね肉皮なし100g', 'calories': 165},
    {'name': '白米1杯', 'calories': 252},
    {'name': '納豆1パック', 'calories': 100},
    {'name': '卵1個', 'calories': 80},
    {'name': '牛乳200ml', 'calories': 134},
    {'name': 'バナナ1本', 'calories': 86},
    {'name': 'りんご1個', 'calories': 54},
    {'name': 'ヨーグルト100g', 'calories': 62},
    {'name': 'サラダ（レタス、トマト）', 'calories': 30},
    {'name': '味噌汁1杯', 'calories': 50},
    {'name': '焼き魚1切れ', 'calories': 120},
    {'name': '豆腐1/2丁', 'calories': 72},
    {'name': '玄米1杯', 'calories': 218},
    {'name': 'サツマイモ1個', 'calories': 140},
  ];

  // 運動参考例のリスト
  final List<Map<String, dynamic>> _exerciseExamples = [
    {'name': 'ウォーキング20分', 'calories': -80},
    {'name': 'ジョギング10分', 'calories': -100},
    {'name': '筋トレ20分', 'calories': -120},
    {'name': '水泳30分', 'calories': -200},
    {'name': '自転車30分', 'calories': -150},
    {'name': 'ヨガ30分', 'calories': -90},
    {'name': 'ストレッチ15分', 'calories': -30},
    {'name': 'ダンス30分', 'calories': -180},
    {'name': '階段上り10分', 'calories': -70},
    {'name': 'ランニング15分', 'calories': -150},
  ];

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
      // 前日のデータを履歴へ保存し、今日の記録を空にする
      final recordsString = prefs.getString('records');
      final exerciseRecordsString = prefs.getString('exercise_records');
      List<Map<String, dynamic>> records = [];
      List<Map<String, dynamic>> exercises = [];
      if (recordsString != null) {
        records = List<Map<String, dynamic>>.from(
          jsonDecode(recordsString).map((x) => Map<String, dynamic>.from(x)),
        );
      }
      if (exerciseRecordsString != null) {
        exercises = List<Map<String, dynamic>>.from(
          jsonDecode(exerciseRecordsString).map((x) => Map<String, dynamic>.from(x)),
        );
      }

      // lastKey の分だけを抽出して履歴保存
      final lastMeals = records.where((r) => r['date'] == lastKey).map((r) => {
        'food': r['food'],
        'calories': (r['calorie'] as num?)?.toInt() ?? 0,
      }).toList();
      final lastExercises = exercises.where((r) => r['date'] == lastKey).map((r) => {
        'exercise': r['exercise'],
        'calories': (r['calorie'] as num?)?.toInt() ?? 0,
      }).toList();

      if (lastMeals.isNotEmpty || lastExercises.isNotEmpty) {
        await DataStorage.saveDaySummary(lastKey, meals: lastMeals, exercises: lastExercises);
      }

      // 前日分を除いた残りのみを保存（＝ほぼ空になる想定）
      final remainingRecords = records.where((r) => r['date'] != lastKey).toList();
      final remainingExercises = exercises.where((r) => r['date'] != lastKey).toList();
      await prefs.setString('records', jsonEncode(remainingRecords));
      await prefs.setString('exercise_records', jsonEncode(remainingExercises));

      // 今日を last_active_day として保存
      await prefs.setString('last_active_day', nowKey);

      if (mounted) {
        setState(() {
          _records = remainingRecords.cast<Map<String, dynamic>>();
          _exerciseRecords = remainingExercises.cast<Map<String, dynamic>>();
          _isCompleted = false; // 新しい日なので未完了
          _calculateTotalCalories();
          _calculateTotalExerciseCalories();
        });
      }
    }
  }

  Future<void> _loadData() async {
    await _loadRecords();
    await _loadExerciseRecords();
    await _loadTargetCalories();
    await _loadTodayWeight();
    await _checkTodayCompletion();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString('records');
    if (recordsString != null) {
      setState(() {
        _records = List<Map<String, dynamic>>.from(
          jsonDecode(recordsString).map((x) => Map<String, dynamic>.from(x))
        );
        _calculateTotalCalories();
      });
    }
  }

  Future<void> _loadExerciseRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final exerciseRecordsString = prefs.getString('exercise_records');
    if (exerciseRecordsString != null) {
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
    setState(() {
      _targetCalories = targetCalories;
    });
  }

  Future<void> _loadTodayWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final weightString = prefs.getString('weight_$today');
    if (weightString != null) {
      setState(() {
        _todayWeight = double.tryParse(weightString);
      });
    }
  }

  Future<void> _checkTodayCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completed = prefs.getBool('completed_$today') ?? false;
    setState(() {
      _isCompleted = completed;
    });
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
        const SnackBar(content: Text('食事参考例を選択してください')),
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
        const SnackBar(content: Text('運動参考例を選択してください')),
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
        SnackBar(content: Text('運動を記録しました！(${calories.abs()}kcal消費)')),
      );
    }
  }

  Future<void> _saveManualExercise() async {
    final exercise = _exerciseController.text;
    final calories = double.tryParse(_exerciseCalorieController.text) ?? 0;

    if (exercise.isEmpty || calories == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('運動名と消費カロリーを入力してください')),
        );
      }
      return;
    }

    // 消費カロリーは負の値として保存
    await _saveExerciseRecord(exercise, -calories.abs());

    _exerciseController.clear();
    _exerciseCalorieController.clear();
  }

  Future<void> _saveWeight() async {
    final weight = double.tryParse(_weightController.text);
    if (weight != null) {
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
        debugPrint('Failed to sync weight to health app: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('体重を記録しました！')),
        );
      }
    }
  }

  Future<void> _saveRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final food = _foodController.text;
    final cal = double.tryParse(_calorieController.text) ?? 0;
    final date = DateTime.now().toIso8601String().split('T')[0];

    if (food.isEmpty || cal == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('食事内容とカロリーを入力してください')),
        );
      }
      return;
    }

    final record = {'food': food, 'calorie': cal, 'date': date};
    _records.add(record);

    await prefs.setString('records', jsonEncode(_records));

    _foodController.clear();
    _calorieController.clear();
    setState(() {
      _calculateTotalCalories();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('食事を記録しました！')),
      );
    }
  }

  Future<void> _deleteFoodRecord(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _records.removeAt(index);
    await prefs.setString('records', jsonEncode(_records));
    setState(() {
      _calculateTotalCalories();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('食事記録を削除しました')),
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
        const SnackBar(content: Text('運動記録を削除しました')),
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
        title: const Text('食事記録を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodController,
              decoration: const InputDecoration(labelText: '食事内容'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _calorieController,
              decoration: const InputDecoration(labelText: 'カロリー (kcal)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final food = _foodController.text;
              final cal = double.tryParse(_calorieController.text) ?? 0;
              
              if (food.isEmpty || cal == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('食事内容とカロリーを入力してください')),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              _records[index] = {'food': food, 'calorie': cal, 'date': record['date']};
              await prefs.setString('records', jsonEncode(_records));
              
              setState(() {
                _calculateTotalCalories();
              });
              
              _foodController.clear();
              _calorieController.clear();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('食事記録を更新しました')),
                );
              }
            },
            child: const Text('更新'),
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
        title: const Text('運動記録を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _exerciseController,
              decoration: const InputDecoration(labelText: '運動名'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _exerciseCalorieController,
              decoration: const InputDecoration(labelText: '消費カロリー (kcal)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final exercise = _exerciseController.text;
              final calories = double.tryParse(_exerciseCalorieController.text) ?? 0;
              
              if (exercise.isEmpty || calories == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('運動名と消費カロリーを入力してください')),
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
                  const SnackBar(content: Text('運動記録を更新しました')),
                );
              }
            },
            child: const Text('更新'),
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
        title: const Text(
          '食事内容',
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
                        const Text(
                          '今日の体重',
                          style: TextStyle(
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
                            decoration: const InputDecoration(
                              labelText: '体重 (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.scale),
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
                          child: const Text('記録'),
                        ),
                      ],
                    ),
                    if (_todayWeight != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        '記録済み: ${_todayWeight!.toStringAsFixed(1)} kg',
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
                      const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.pink, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'カロリー状況',
                            style: TextStyle(
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
                          _buildCalorieInfo('目標', _targetCalories!.toStringAsFixed(0), Colors.blue),
                          _buildCalorieInfo('摂取', _totalCalories.toStringAsFixed(0), Colors.orange),
                          _buildCalorieInfo('運動', _totalExerciseCalories.abs().toStringAsFixed(0), Colors.green),
                          _buildCalorieInfo('残り', _remainingCalories?.toStringAsFixed(0) ?? "0", 
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
                        const Text(
                          '運動記録',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                                         // 運動参考例ドロップダウン
                     Row(
                       children: [
                         Expanded(
                           child: DropdownButtonFormField<String>(
                             value: _selectedExerciseExample,
                             decoration: const InputDecoration(
                               labelText: '運動参考例を選択',
                               border: OutlineInputBorder(),
                               prefixIcon: Icon(Icons.sports),
                             ),
                             hint: const Text('運動参考例を選択してください'),
                             onChanged: (value) {
                               setState(() {
                                 _selectedExerciseExample = value;
                               });
                             },
                             items: _exerciseExamples.map((example) {
                               return DropdownMenuItem<String>(
                                 value: example['name'],
                                 child: Text('${example['name']} (${example['calories'].abs()}kcal消費)'),
                               );
                             }).toList(),
                           ),
                         ),
                         const SizedBox(width: 10),
                         ElevatedButton(
                           onPressed: _addExerciseExample,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.green,
                             foregroundColor: Colors.white,
                             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                           ),
                           child: const Text('追加'),
                         ),
                       ],
                     ),
                     const SizedBox(height: 15),
                     
                     // 手動入力欄
                     Row(
                       children: [
                         Expanded(
                           child: TextField(
                             controller: _exerciseController,
                             decoration: const InputDecoration(
                               labelText: '運動名',
                               border: OutlineInputBorder(),
                               prefixIcon: Icon(Icons.edit),
                             ),
                           ),
                         ),
                         const SizedBox(width: 10),
                         Expanded(
                           child: TextField(
                             controller: _exerciseCalorieController,
                             decoration: const InputDecoration(
                               labelText: '消費カロリー (kcal)',
                               border: OutlineInputBorder(),
                               prefixIcon: Icon(Icons.local_fire_department),
                             ),
                             keyboardType: TextInputType.number,
                           ),
                         ),
                       ],
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
                         child: const Text(
                           '運動を記録',
                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        const Text(
                          '食事記録',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // 参考例ドロップダウン
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedFoodExample,
                            decoration: const InputDecoration(
                              labelText: '参考例を選択',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.list),
                            ),
                            hint: const Text('参考例を選択してください'),
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
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addFoodExample,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          ),
                          child: const Text('追加'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    TextField(
                      controller: _foodController,
                      decoration: const InputDecoration(
                        labelText: '食事内容',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _calorieController,
                      decoration: const InputDecoration(
                        labelText: 'カロリー (kcal)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department),
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
                            child: const Text(
                              '記録を保存',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                          const Text(
                            '今日の記録',
                            style: TextStyle(
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
                        const Text(
                          '食事',
                          style: TextStyle(
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
                        const Text(
                          '運動',
                          style: TextStyle(
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

