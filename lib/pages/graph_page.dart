import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_storage.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadGraphData() async {
    try {
      final data = await DataStorage.loadGraphData();
      if (mounted) {
        setState(() {
          _allData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの読み込みに失敗しました: $e')),
        );
      }
    }
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
    if (isoDate.length >= 10) {
      final String mm = isoDate.substring(5, 7);
      final String dd = isoDate.substring(8, 10);
      final String m = mm.startsWith('0') ? mm.substring(1) : mm;
      final String d = dd.startsWith('0') ? dd.substring(1) : dd;
      return '$m/$d';
    }
    return isoDate;
  }

  Future<double?> _getTargetWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetWeight = prefs.getDouble('targetWeight');
      return targetWeight;
    } catch (e) {
      return null;
    }
  }

  Future<double> _getWeightMinY() async {
    final targetWeight = await _getTargetWeight();
    if (targetWeight != null) {
      return targetWeight - 20.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t?.graphTitle ?? '体重＆カロリーグラフ',
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.lightBlue),
                      const SizedBox(height: 20),
                      Text(
                        t?.loadingData ?? 'データを読み込み中...',
                        style: const TextStyle(
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.show_chart,
                            size: 60,
                            color: Colors.lightBlue,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            t?.noGraphData ?? 'まだデータがありません',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t?.addMealsForGraph ?? '食事記録を追加してグラフを表示しましょう！',
                            style: const TextStyle(
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<int>(
                            value: _spanDays,
                            items: [
                              DropdownMenuItem(value: 7, child: Text(t?.span7Days ?? '7日')),
                              DropdownMenuItem(value: 14, child: Text(t?.span14Days ?? '14日')),
                              DropdownMenuItem(value: 31, child: Text(t?.span31Days ?? '31日')),
                              DropdownMenuItem(value: 0, child: Text(t?.spanAll ?? '全期間')),
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
                          final int maxTicks = 6;
                          final int interval = n <= 1 ? 1 : (n / maxTicks).ceil();
                          return Column(
                            children: [
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
                                        Text(
                                          t?.weightTrend ?? '体重の推移',
                                          style: const TextStyle(
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
                                        return SizedBox(
                                          height: 200,
                                          child: LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: true,
                                                horizontalInterval: 5, // 2から5に戻す
                                                verticalInterval: 1,
                                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                                                getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 28,
                                                    interval: interval.toDouble(),
                                                    getTitlesWidget: (double value, TitleMeta meta) {
                                                      final int idx = value.toInt();
                                                      if (idx < 0 || idx >= n) return const SizedBox.shrink();
                                                      if (idx % interval != 0 && idx != n - 1) return const SizedBox.shrink();
                                                      final label = _formatDateLabel(dates[idx]);
                                                      return SideTitleWidget(
                                                        axisSide: meta.axisSide,
                                                        child: Text(
                                                          label,
                                                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    interval: 5, // 2から5に戻す
                                                    getTitlesWidget: (double value, TitleMeta meta) => Text(
                                                      '${value.toInt()}${t?.unitKg ?? 'kg'}',
                                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                                    ),
                                                    reservedSize: 50,
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                                              minX: 0,
                                              maxX: weightSpots.isEmpty ? 0 : weightSpots.length.toDouble() - 1,
                                              minY: weightSpots.isEmpty ? 0 : (weightSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 2).clamp(0.0, double.infinity),
                                              maxY: weightSpots.isEmpty ? 100 : (weightSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: weightSpots,
                                                  isCurved: true,
                                                  gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                                                  barWidth: 4, // 3から4に変更
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.blue, strokeWidth: 3, strokeColor: Colors.white), // サイズを大きく
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
                                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                                        const SizedBox(width: 10),
                                        Text(
                                          t?.calorieTrend ?? 'カロリー摂取の推移',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
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
                                            horizontalInterval: 400, // 500から400に変更
                                            verticalInterval: 1,
                                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                                            getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 28,
                                                interval: interval.toDouble(),
                                                getTitlesWidget: (double value, TitleMeta meta) {
                                                  final int idx = value.toInt();
                                                  if (idx < 0 || idx >= n) return const SizedBox.shrink();
                                                  if (idx % interval != 0 && idx != n - 1) return const SizedBox.shrink();
                                                  final label = _formatDateLabel(dates[idx]);
                                                  return SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                                                  );
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 400, // 500から400に変更
                                                getTitlesWidget: (double value, TitleMeta meta) => Text(
                                                  '${value.toInt()}${t?.unitKcal ?? 'kcal'}',
                                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                                reservedSize: 60,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                                          minX: 0,
                                          maxX: calorieSpots.isEmpty ? 0 : calorieSpots.length.toDouble() - 1,
                                          minY: 0,
                                          maxY: calorieSpots.isEmpty ? 2000 : (calorieSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) > 2000 ? 
                                                 (calorieSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 200).roundToDouble() : 2000),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: calorieSpots,
                                              isCurved: true,
                                              gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.orange, strokeWidth: 2, strokeColor: Colors.white),
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
