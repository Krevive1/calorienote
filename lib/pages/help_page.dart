import 'package:flutter/material.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t?.helpTitle ?? 'ヘルプ',
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
            children: [
              _buildHelpSection(
                t?.howToUse ?? 'アプリの使い方',
                [
                  _buildHelpItem(
                    '1. ' + (t?.setupTitle ?? '初期設定'),
                    t?.helpSetupDesc ?? '初回起動時に年齢、身長、体重、目標体重、目標日数を入力してカロリー計算を行います。',
                    Icons.settings,
                  ),
                  _buildHelpItem(
                    '2. ' + (t?.menuRecord ?? '食事記録'),
                    t?.helpMealDesc ?? '食事内容とカロリーを入力して記録します。参考例から選択することもできます。',
                    Icons.restaurant,
                  ),
                  _buildHelpItem(
                    '3. ' + (t?.exerciseTitle ?? '運動記録'),
                    t?.helpExerciseDesc ?? '運動内容と消費カロリーを記録します。運動参考例から選択することもできます。',
                    Icons.fitness_center,
                  ),
                  _buildHelpItem(
                    '4. ' + (t?.weightTitle ?? '体重記録'),
                    t?.helpWeightDesc ?? '毎日の体重を記録して進捗を管理します。',
                    Icons.monitor_weight,
                  ),
                  _buildHelpItem(
                    '5. ' + (t?.menuGraph ?? 'グラフ確認'),
                    t?.helpGraphDesc ?? '記録したデータをグラフで確認して進捗を把握します。',
                    Icons.show_chart,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                t?.faqTitle ?? 'よくある質問',
                [
                  _buildHelpItem(
                    t?.faqCalorieCalc ?? 'Q: カロリー計算はどのように行われますか？',
                    t?.faqCalorieCalcAnswer ?? 'A: ハリスベネディクト方程式を使用して基礎代謝を計算し、活動係数と目標体重を考慮して1日の摂取カロリーを算出します。',
                    Icons.help,
                  ),
                  _buildHelpItem(
                    t?.faqDataStorage ?? 'Q: データはどこに保存されますか？',
                    t?.faqDataStorageAnswer ?? 'A: データはデバイス内に安全に保存されます。アプリを削除するとデータも削除されます。',
                    Icons.storage,
                  ),
                  _buildHelpItem(
                    t?.faqTargetCalorie ?? 'Q: 目標カロリーを変更できますか？',
                    t?.faqTargetCalorieAnswer ?? 'A: 設定画面から目標カロリーを変更できます。',
                    Icons.edit,
                  ),
                  _buildHelpItem(
                    t?.faqPastRecords ?? 'Q: 過去の記録を確認できますか？',
                    t?.faqPastRecordsAnswer ?? 'A: 記録一覧画面で過去の記録を確認できます。',
                    Icons.history,
                  ),
                  _buildHelpItem(
                    t?.faqExportData ?? 'Q: データをエクスポートできますか？',
                    t?.faqExportDataAnswer ?? 'A: 設定画面のデータ共有機能でCSVファイルとしてエクスポートできます。',
                    Icons.share,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                t?.calorieCalcTitle ?? 'カロリー計算について',
                [
                  _buildHelpItem(
                    t?.calorieCalcBasalMetabolism ?? '基礎代謝の計算',
                    t?.calorieCalcBasalMetabolismDesc ?? 'ハリスベネディクト方程式を使用：\n男性: 13.397×体重 + 4.799×身長 - 5.677×年齢 + 88.362\n女性: 9.247×体重 + 3.098×身長 - 4.33×年齢 + 447.593',
                    Icons.calculate,
                  ),
                  _buildHelpItem(
                    t?.calorieCalcActivityFactor ?? '活動係数',
                    t?.calorieCalcActivityFactorDesc ?? '• あまり運動しない: 1.2\n• 軽い運動: 1.375\n• 中程度の運動: 1.55\n• 激しい運動: 1.725',
                    Icons.directions_run,
                  ),
                  _buildHelpItem(
                    t?.calorieCalcTargetCalorie ?? '目標カロリー',
                    t?.calorieCalcTargetCalorieDesc ?? '総消費カロリー - 減量に必要なカロリー + 300kcal（余裕を持たせるため）',
                    Icons.track_changes,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                t?.healthManagementTitle ?? '健康管理のコツ',
                [
                  _buildHelpItem(
                    t?.healthManagementContinuation ?? '継続のポイント',
                    t?.healthManagementContinuationDesc ?? '• 毎日記録する習慣をつける\n• 無理のない目標設定\n• 定期的に進捗を確認する',
                    Icons.trending_up,
                  ),
                  _buildHelpItem(
                    t?.healthManagementDietTips ?? '食事のコツ',
                    t?.healthManagementDietTipsDesc ?? '• バランスの良い食事を心がける\n• 野菜を積極的に摂取\n• 水分補給を忘れずに',
                    Icons.local_dining,
                  ),
                  _buildHelpItem(
                    t?.healthManagementExerciseTips ?? '運動のコツ',
                    t?.healthManagementExerciseTipsDesc ?? '• 無理のない運動から始める\n• 継続しやすい運動を選ぶ\n• 日常生活に運動を取り入れる',
                    Icons.fitness_center,
                  ),
                ],
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
                    const Icon(
                      Icons.support_agent,
                      color: Colors.lightBlue,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t?.contactTitle ?? 'お問い合わせ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t?.contactDescription ?? 'アプリの使い方でお困りの場合は、以下までお問い合わせください。',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t?.contactEmail ?? 'Email: qgsky217@yahoo.co.jp',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlue.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.lightBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
