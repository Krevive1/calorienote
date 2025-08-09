import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  Map<String, dynamic> _allData = {};
  bool _isLoading = true;
  int _spanDays = 14; // 7, 14, 31, 0(全期間)

  @override
  void initState() {
    super.initState();
    _loadGraphData();
  }

  void _loadGraphData() async {
    final data = await DataStorage.loadGraphData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  List<String> _getDisplayedDates() {
    final List<String> dates = _allData.keys.toList()..sort();
    if (_spanDays <= 0 || dates.length <= _spanDays) {
      return dates;
    }
    return dates.sublist(dates.length - _spanDays);
  }

  List<FlSpot> _getWeightSpots(List<String> dates) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      final dayData = _allData[dates[i]];
      if (dayData['weight'] != null) {
        final double weight = (dayData['weight'] * 1.0);
        spots.add(FlSpot(i.toDouble(), weight));
      }
    }
    return spots;
  }

  List<FlSpot> _getCalorieSpots(List<String> dates) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      final dayData = _allData[dates[i]];
      if (dayData['totalCalories'] != null) {
        final double cal = (dayData['totalCalories'] * 1.0);
        spots.add(FlSpot(i.toDouble(), cal));
      }
    }
    return spots;
  }

  String _formatDateLabel(String isoDate) {
    // isoDate: YYYY-MM-DD → MM/DD 表示
    if (isoDate.length >= 10) {
      final String mm = isoDate.substring(5, 7);
      final String dd = isoDate.substring(8, 10);
      // 先頭ゼロを取り除く
      final String m = mm.startsWith('0') ? mm.substring(1) : mm;
      final String d = dd.startsWith('0') ? dd.substring(1) : dd;
      return '$m/$d';
    }
    return isoDate;
  }

  // 目標体重を取得するメソッド
  Future<double?> _getTargetWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetWeight = prefs.getDouble('targetWeight');
      print('取得した目標体重: $targetWeight'); // デバッグ用ログ
      
      // すべての保存された値を確認
      final allKeys = prefs.getKeys();
      print('保存されているすべてのキー: $allKeys');
      
      return targetWeight;
    } catch (e) {
      print('目標体重取得エラー: $e'); // デバッグ用ログ
      return null;
    }
  }

  // 体重グラフのY軸最小値を計算するメソッド
  Future<double> _getWeightMinY() async {
    final targetWeight = await _getTargetWeight();
    print('_getWeightMinY: targetWeight = $targetWeight'); // デバッグ用ログ
    
    if (targetWeight != null) {
      // 目標体重の-20kgを最小値として設定
      final minY = targetWeight - 20.0;
      print('計算されたminY: $minY (目標体重: $targetWeight - 20kg)'); // デバッグ用ログ
      return minY;
    }
    print('目標体重が設定されていないため、minYを0に設定'); // デバッグ用ログ
    // 目標体重が設定されていない場合は0を返す
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '体重＆カロリーグラフ',
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
        child: _isLoading
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.lightBlue),
                      SizedBox(height: 20),
                      Text(
                        'データを読み込み中...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _allData.isEmpty
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
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 60,
                            color: Colors.lightBlue,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'まだデータがありません',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '食事記録を追加してグラフを表示しましょう！',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 表示期間セレクタ
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<int>(
                            value: _spanDays,
                            items: const [
                              DropdownMenuItem(value: 7, child: Text('7日')),
                              DropdownMenuItem(value: 14, child: Text('14日')),
                              DropdownMenuItem(value: 31, child: Text('31日')),
                              DropdownMenuItem(value: 0, child: Text('全期間')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _spanDays = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        Builder(builder: (context) {
                          final dates = _getDisplayedDates();
                          final weightSpots = _getWeightSpots(dates);
                          final calorieSpots = _getCalorieSpots(dates);
                          final int n = dates.length;

                          // 目盛りを約6個に間引く
                          final int maxTicks = 6;
                          final int interval = n <= 1 ? 1 : (n / maxTicks).ceil();

                          return Column(
                            children: [
                              // 体重グラフ
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
                                        const Icon(
                                          Icons.monitor_weight,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          '体重の推移',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                                                         FutureBuilder<double>(
                                       future: _getWeightMinY(),
                                       builder: (context, snapshot) {
                                         final minY = snapshot.data ?? 0.0;
                                         print('FutureBuilder: minY = $minY'); // デバッグ用ログ
                                         return SizedBox(
                                          height: 200,
                                          child: LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: true,
                                                horizontalInterval: 5, // 体重グラフの水平グリッド間隔を5kgに
                                                verticalInterval: 1,
                                                getDrawingHorizontalLine: (value) {
                                                  return FlLine(
                                                    color: Colors.grey.shade300,
                                                    strokeWidth: 1,
                                                  );
                                                },
                                                getDrawingVerticalLine: (value) {
                                                  return FlLine(
                                                    color: Colors.grey.shade300,
                                                    strokeWidth: 1,
                                                  );
                                                },
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                topTitles: AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 28,
                                                    interval: interval.toDouble(),
                                                    getTitlesWidget: (double value, TitleMeta meta) {
                                                      final int idx = value.toInt();
                                                      if (idx < 0 || idx >= n) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      // intervalに該当しないindexは非表示
                                                      if (idx % interval != 0 && idx != n - 1) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      final label = _formatDateLabel(dates[idx]);
                                                      return SideTitleWidget(
                                                        axisSide: meta.axisSide,
                                                        child: Text(
                                                          label,
                                                          style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    interval: 5, // 5kg間隔に変更
                                                    getTitlesWidget: (double value, TitleMeta meta) {
                                                      return Text(
                                                        '${value.toInt()}kg',
                                                        style: const TextStyle(
                                                          color: Colors.black87, // より見やすい色に変更
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14, // フォントサイズを大きく
                                                        ),
                                                      );
                                                    },
                                                    reservedSize: 50, // 予約サイズを大きく
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: true,
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              minX: 0,
                                              maxX: weightSpots.isEmpty ? 0 : weightSpots.length.toDouble() - 1,
                                              minY: minY, // 動的に計算された最小値を使用
                                              maxY: weightSpots.isEmpty ? 100 : (weightSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 5), // 最大値に余裕を持たせる
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: weightSpots,
                                                  isCurved: true,
                                                  gradient: LinearGradient(
                                                    colors: [Colors.blue, Colors.lightBlue],
                                                  ),
                                                  barWidth: 3,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot, percent, barData, index) {
                                                      return FlDotCirclePainter(
                                                        radius: 4,
                                                        color: Colors.blue,
                                                        strokeWidth: 2,
                                                        strokeColor: Colors.white,
                                                      );
                                                    },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.blue.withValues(alpha: 0.3),
                                                        Colors.blue.withValues(alpha: 0.1),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // カロリーグラフ
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
                                        const Icon(
                                          Icons.local_fire_department,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'カロリー摂取の推移',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 200,
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            horizontalInterval: 500, // カロリーグラフの水平グリッド間隔を500kcalに
                                            verticalInterval: 1,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey.shade300,
                                                strokeWidth: 1,
                                              );
                                            },
                                            getDrawingVerticalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey.shade300,
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(showTitles: false),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(showTitles: false),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 28,
                                                interval: interval.toDouble(),
                                                getTitlesWidget: (double value, TitleMeta meta) {
                                                  final int idx = value.toInt();
                                                  if (idx < 0 || idx >= n) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  if (idx % interval != 0 && idx != n - 1) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  final label = _formatDateLabel(dates[idx]);
                                                  return SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(
                                                      label,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 500, // 500kcal間隔に変更
                                                getTitlesWidget: (double value, TitleMeta meta) {
                                                  return Text(
                                                    '${value.toInt()}kcal',
                                                    style: const TextStyle(
                                                      color: Colors.black87, // より見やすい色に変更
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14, // フォントサイズを大きく
                                                    ),
                                                  );
                                                },
                                                reservedSize: 60, // 予約サイズを大きく（kcalは文字数が多いため）
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          minX: 0,
                                          maxX: calorieSpots.isEmpty ? 0 : calorieSpots.length.toDouble() - 1,
                                          minY: 0,
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: calorieSpots,
                                              isCurved: true,
                                              gradient: LinearGradient(
                                                colors: [Colors.orange, Colors.red],
                                              ),
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent, barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: Colors.orange,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.orange.withValues(alpha: 0.3),
                                                    Colors.orange.withValues(alpha: 0.1),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
