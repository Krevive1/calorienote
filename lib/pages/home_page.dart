import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_page.dart';
import 'record_page.dart';
import 'record_list_page.dart';
import 'graph_page.dart';
import 'data_storage.dart';
import 'settings_page.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/rewarded_ad_button.dart';
import '../services/ad_service.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? _targetCalories;
  double _todayCalories = 0.0;
  bool _settingsChangedHandled = false;

  @override
  void initState() {
    super.initState();
    _loadTargetCalories();
    _loadTodayCalories();
    _loadInterstitialAd();

    // 初回マウント後に一度だけ、遷移引数を確認してメッセージを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_settingsChangedHandled) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['settingsChanged'] == true) {
        _settingsChangedHandled = true;
        ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
          content: Text(AppLocalizations.of(context)?.settingsChangedSnack ?? '設定を変更しました'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面が表示されるたびに目標カロリーを再計算して読み込み
    _recalculateTargetCalories();
    // 今日の摂取カロリーも再読み込み
    _loadTodayCalories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTargetCalories() async {
    final targetCalories = await DataStorage.loadDailyTargetCalories();
    if (mounted) {
      setState(() {
        _targetCalories = targetCalories;
      });
    }
  }

  Future<void> _loadTodayCalories() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final meals = await DataStorage.loadMeals(today);
      
      double totalCalories = 0.0;
      for (var meal in meals) {
        if (meal['calories'] != null) {
          totalCalories += (meal['calories'] as num).toDouble();
        }
      }
      
      if (mounted) {
        setState(() {
          _todayCalories = totalCalories;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _todayCalories = 0.0;
        });
      }
    }
  }

  // 目標カロリーを再計算するメソッド
  Future<void> _recalculateTargetCalories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final age = prefs.getInt('age');
      final currentWeight = prefs.getDouble('currentWeight');
      final height = prefs.getDouble('height');
      final goalDays = prefs.getInt('goalDays');
      final targetWeight = prefs.getDouble('targetWeight');
      final gender = prefs.getString('gender') ?? '女性';
      final activityFactor = prefs.getDouble('activityFactor') ?? 1.2;

      if (age != null && currentWeight != null && height != null && goalDays != null && targetWeight != null) {
        // 基礎代謝を計算
        final bmr = gender == '男性'
            ? 13.397 * currentWeight + 4.799 * height - 5.677 * age + 88.362
            : 9.247 * currentWeight + 3.098 * height - 4.330 * age + 447.593;

        final tdee = bmr * activityFactor;
        final weightLossPerDay = (currentWeight - targetWeight) / goalDays;
        final calorieDeficit = weightLossPerDay * 7700;
        final recommended = tdee - calorieDeficit;

        // 新しい目標カロリーを保存
        await DataStorage.saveDailyTargetCalories(recommended);
        
        // ホームページの表示を更新
        if (mounted) {
          setState(() {
            _targetCalories = recommended;
          });
        }
      }
    } catch (e) {
      // エラーハンドリング（デバッグログを削除）
    }
  }

  Future<void> _loadInterstitialAd() async {
    await AdService.loadInterstitialAd();
  }

  Future<void> _navigateWithAd(VoidCallback navigation) async {
    await AdService.showInterstitialAd();
    navigation();
    // 次の画面遷移のために広告を再読み込み
    _loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t?.homeTitle ?? 'カロリーノート',
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
          IconButton(
            icon: const Icon(Icons.settings, size: 24),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              // 設定画面から戻った時に目標カロリーを再読み込み
              _loadTargetCalories();
            },
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
              // 目標カロリー表示カード
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
                      const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)?.todayTargetCalories ?? '今日の目標カロリー',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_targetCalories!.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.restaurant,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${AppLocalizations.of(context)?.consumedCalories ?? '摂取済み'}: ${_todayCalories.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${AppLocalizations.of(context)?.remainingCalories ?? '残り'}: ${(_targetCalories! - _todayCalories).toStringAsFixed(0)} kcal',
                              style: TextStyle(
                                fontSize: 14,
                                color: (_targetCalories! - _todayCalories) >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),
              
              // メニューボタン
              const SizedBox(height: 30),
              _buildMenuButton(
                context,
                t?.menuRecord ?? '食事記録',
                Icons.restaurant,
                Colors.orange,
                () => _navigateWithAd(() {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordPage()))
                      .then((_) {
                    _loadTodayCalories();
                  });
                }),
              ),
              const SizedBox(height: 15),
              _buildMenuButton(
                context,
                t?.menuRecordList ?? '記録一覧',
                Icons.list,
                Colors.green,
                () => _navigateWithAd(() {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordListPage()));
                }),
              ),
              const SizedBox(height: 15),
              _buildMenuButton(
                context,
                t?.menuGraph ?? 'グラフ',
                Icons.show_chart,
                Colors.red,
                () => _navigateWithAd(() {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GraphPage()));
                }),
              ),
              const SizedBox(height: 15),
              _buildMenuButton(
                context,
                t?.menuChangeTarget ?? '目標体重変更',
                Icons.monitor_weight,
                Colors.purple,
                () => _navigateWithAd(() {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InputPage()))
                      .then((_) async {
                    await _recalculateTargetCalories();
                    await _loadTargetCalories();
                    await _loadTodayCalories();
                  });
                }),
              ),
              
              const SizedBox(height: 25),
              
                             // リワード広告ボタン
               RewardedAdButton(
                 buttonText: AppLocalizations.of(context)?.rewardedAdButtonText ?? '広告を見て特別機能を解除',
                 icon: Icons.star,
                 onRewarded: () {
                   // 特別機能の解除処理
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text(AppLocalizations.of(context)?.specialFeatureUnlocked ?? '特別機能が解除されました！'),
                       backgroundColor: Colors.green,
                     ),
                   );
                 },
               ),
              
              const SizedBox(height: 25),
              
              // ヒントカード
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
                    const Icon(
                      Icons.lightbulb,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                                         Text(
                       AppLocalizations.of(context)?.healthTipsTitle ?? '健康管理のヒント',
                       style: const TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                         color: Colors.lightBlue,
                       ),
                     ),
                     const SizedBox(height: 15),
                     Text(
                       AppLocalizations.of(context)?.healthTipsContent ?? '• 毎日食事を記録して、カロリー管理を習慣にしましょう\n• 目標カロリーを意識して、バランスの良い食事を心がけましょう\n• グラフで進捗を確認して、モチベーションを維持しましょう',
                       style: const TextStyle(
                         fontSize: 14,
                         color: Colors.grey,
                         height: 1.5,
                       ),
                     ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // バナー広告
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
