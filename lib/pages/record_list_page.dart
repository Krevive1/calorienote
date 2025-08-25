import 'package:flutter/material.dart';
import 'package:calorie_note/pages/data_storage.dart';
import 'package:calorie_note/services/share_service.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  Map<String, dynamic> allData = {};
  Map<String, int> _calorieCache = {}; // カロリー計算のキャッシュ

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面が表示されるたびにデータを再読み込み（重複を避けるため）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAllData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      print('RecordListPage: データ読み込み開始');
      final data = await DataStorage.loadAllData();
      print('RecordListPage: 読み込まれたデータ: $data');
      print('RecordListPage: データのキー数: ${data.length}');
      
      if (mounted) {
        setState(() {
          allData = data;
          _calorieCache.clear(); // キャッシュをクリア
        });
        print('RecordListPage: データ読み込み完了、allData.length: ${allData.length}');
      }
    } catch (e) {
      print('RecordListPage: データ読み込みエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  int _calculateTotalCalories(dynamic dayData) {
    // キャッシュされた値があれば返す
    final cacheKey = dayData.toString();
    if (_calorieCache.containsKey(cacheKey)) {
      return _calorieCache[cacheKey]!;
    }
    
    int total = 0;
    
    print('RecordListPage._calculateTotalCalories: dayData = $dayData');
    print('RecordListPage._calculateTotalCalories: dayData.runtimeType = ${dayData.runtimeType}');
    
    // 食事カロリーを計算
    if (dayData is Map<String, dynamic> && dayData['meals'] != null) {
      final meals = dayData['meals'] as List<dynamic>;
      print('RecordListPage._calculateTotalCalories: meals = $meals');
      total += meals.fold<int>(0, (sum, meal) {
        if (meal is Map<String, dynamic>) {
          final calories = meal['calories'];
          if (calories is int) return sum + calories;
          if (calories is double) return sum + calories.toInt();
        }
        return sum;
      });
    } else if (dayData is List) {
      // 新しい形式のデータ（直接リスト）
      print('RecordListPage._calculateTotalCalories: dayData is List = $dayData');
      total += dayData.fold<int>(0, (sum, meal) {
        if (meal is Map<String, dynamic>) {
          final calories = meal['calories'];
          if (calories is int) return sum + calories;
          if (calories is double) return sum + calories.toInt();
        }
        return sum;
      });
    }
    
    // 運動カロリーを計算（負の値なので加算）
    if (dayData is Map<String, dynamic> && dayData['exercises'] != null) {
      final exercises = dayData['exercises'] as List<dynamic>;
      total += exercises.fold<int>(0, (sum, exercise) {
        if (exercise is Map<String, dynamic>) {
          final calories = exercise['calories'];
          if (calories is int) return sum + calories;
          if (calories is double) return sum + calories.toInt();
        }
        return sum;
      });
    }
    
    print('RecordListPage._calculateTotalCalories: total = $total');
    
    // 結果をキャッシュ
    _calorieCache[cacheKey] = total;
    return total;
  }

  Future<void> _showShareOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.shareOptionsTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.lightBlue),
              title: Text(AppLocalizations.of(context)!.shareAllDataOption),
              subtitle: Text(AppLocalizations.of(context)!.shareAllDataSubtitle),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ShareService.shareAllDataAsCSV();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラー: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.lightBlue),
              title: Text(AppLocalizations.of(context)!.sharePeriodOption),
              subtitle: Text(AppLocalizations.of(context)!.sharePeriodSubtitle),
              onTap: () async {
                Navigator.pop(context);
                _showDateRangePicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.lightBlue),
              title: Text(AppLocalizations.of(context)!.shareAppOption),
              subtitle: Text(AppLocalizations.of(context)!.shareAppSubtitle),
              onTap: () async {
                Navigator.pop(context);
                await ShareService.shareApp();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.lightBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      try {
        await ShareService.sharePeriodDataAsCSV(picked.start, picked.end);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = allData.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pastMealsTitle,
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
          if (allData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _showShareOptions,
              tooltip: AppLocalizations.of(context)!.shareTooltip,
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
                     children: [
                       Icon(
                         Icons.history,
                         size: 60,
                         color: Colors.lightBlue,
                       ),
                       const SizedBox(height: 20),
                       Text(
                         AppLocalizations.of(context)!.noMealRecords,
                         style: const TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: Colors.lightBlue,
                         ),
                       ),
                       const SizedBox(height: 10),
                       Text(
                         AppLocalizations.of(context)!.startRecording,
                         style: const TextStyle(
                           color: Colors.grey,
                         ),
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 20),
                     ],
                   ),
                 ),
               )
            : RefreshIndicator(
                onRefresh: _loadAllData,
                child: ListView.builder(
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
                        '${AppLocalizations.of(context)!.total}: $totalCalories ${AppLocalizations.of(context)!.kcal}',
                        style: TextStyle(
                          color: totalCalories >= 0 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                                             children: [
                         // 食事記録
                         if (dayData is Map<String, dynamic> && dayData['meals'] != null) ...[
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.meals,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.orange, size: 20),
                                  onPressed: () async {
                                    try {
                                      await ShareService.shareMealRecord(date, dayData);
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('共有エラー: $e')),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: AppLocalizations.of(context)!.shareThisDayRecord,
                                ),
                              ],
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
                                          meal['food'] ?? meal['meal'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '+${meal['calories'] ?? 0} ${AppLocalizations.of(context)!.kcal}',
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
                           // 新しい形式のデータ（直接リスト）
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.meals,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.orange, size: 20),
                                  onPressed: () async {
                                    try {
                                      await ShareService.shareMealRecord(date, dayData);
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('共有エラー: $e')),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: AppLocalizations.of(context)!.shareThisDayRecord,
                                ),
                              ],
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
                                          meal['food'] ?? meal['meal'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '+${meal['calories'] ?? 0} ${AppLocalizations.of(context)!.kcal}',
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
                        if (dayData is Map<String, dynamic> && dayData['exercises'] != null) ...[
                          if (dayData['meals'] != null || dayData is List) 
                            const Divider(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              AppLocalizations.of(context)!.exercises,
                              style: const TextStyle(
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
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${exercise['calories'] ?? 0} ${AppLocalizations.of(context)!.kcal}',
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
      ),
    );
  }
}
