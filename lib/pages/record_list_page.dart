import 'package:flutter/material.dart';
import 'package:calorie_note/pages/data_storage.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  Map<String, dynamic> allData = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final data = await DataStorage.loadAllData();
    setState(() {
      allData = data;
    });
  }

  int _calculateTotalCalories(dynamic dayData) {
    int total = 0;
    
    // 食事カロリーを計算
    if (dayData is Map<String, dynamic> && dayData['meals'] != null) {
      final meals = dayData['meals'] as List<dynamic>;
      total += meals.fold<int>(0, (sum, meal) => sum + ((meal['calories'] as int?) ?? 0));
    } else if (dayData is List) {
      // 古い形式のデータ対応
      total += dayData.fold<int>(0, (sum, meal) => sum + ((meal['calories'] as int?) ?? 0));
    }
    
    // 運動カロリーを計算（負の値なので加算）
    if (dayData is Map<String, dynamic> && dayData['exercises'] != null) {
      final exercises = dayData['exercises'] as List<dynamic>;
      total += exercises.fold<int>(0, (sum, exercise) => sum + ((exercise['calories'] as int?) ?? 0));
    }
    
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = allData.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '過去食事',
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
        child: allData.isEmpty
            ? Center(
                child: Container(
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
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.history,
                        size: 60,
                        color: Colors.lightBlue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'まだ食事記録がありません',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '食事内容ページで記録を始めましょう！',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final date = sortedKeys[index];
                  final dayData = allData[date];
                  final totalCalories = _calculateTotalCalories(dayData);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
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
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.lightBlue,
                      ),
                      title: Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.lightBlue,
                        ),
                      ),
                      subtitle: Text(
                        '合計: $totalCalories kcal',
                        style: TextStyle(
                          color: totalCalories >= 0 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        // 食事記録
                        if (dayData['meals'] != null) ...[
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              '食事',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...((dayData['meals'] as List<dynamic>).map<Widget>((meal) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.restaurant,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meal['food'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '+${meal['calories'] ?? 0} kcal',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                        ] else if (dayData is List) ...[
                          // 古い形式のデータ対応
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              '食事',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                          ),
                                                     ...(dayData.map<Widget>((meal) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.restaurant,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meal['meal'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '+${meal['calories'] ?? 0} kcal',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                        ],
                        
                        // 運動記録
                        if (dayData['exercises'] != null) ...[
                          if (dayData['meals'] != null || dayData is List) 
                            const Divider(height: 30),
                          const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              '運動',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...((dayData['exercises'] as List<dynamic>).map<Widget>((exercise) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise['exercise'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${exercise['calories'] ?? 0} kcal',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
