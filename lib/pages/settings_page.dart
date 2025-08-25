import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calorie_note/pages/data_storage.dart';
import 'package:calorie_note/services/share_service.dart';
import 'package:calorie_note/services/dummy_data_service.dart';
import 'privacy_policy_page.dart';
import 'help_page.dart';
import '../services/locale_service.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double? _targetCalories;
  bool _notificationsEnabled = false;
  bool _syncWeight = false;
  bool _syncSteps = false;
  bool _syncCalories = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final targetCalories = await DataStorage.loadDailyTargetCalories();
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    final syncWeight = prefs.getBool('sync_weight') ?? false;
    final syncSteps = prefs.getBool('sync_steps') ?? false;
    final syncCalories = prefs.getBool('sync_calories') ?? false;

    setState(() {
      _targetCalories = targetCalories;
      _notificationsEnabled = notificationsEnabled;
      _syncWeight = syncWeight;
      _syncSteps = syncSteps;
      _syncCalories = syncCalories;
    });
  }

  Future<void> _updateTargetCalories(double? value) async {
    if (value != null && value > 0) {
      await DataStorage.saveDailyTargetCalories(value);
      setState(() {
        _targetCalories = value;
      });
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t?.settingsChangedSnack ?? '設定を変更しました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updateSyncSettings(String type, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_$type', value);
    setState(() {
      switch (type) {
        case 'weight':
          _syncWeight = value;
          break;
        case 'steps':
          _syncSteps = value;
          break;
        case 'calories':
          _syncCalories = value;
          break;
      }
    });
  }

  Future<void> _showDeleteDataDialog(BuildContext context) async {
    final t = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Text(t?.deleteDataConfirmTitle ?? 'データ削除の確認'),
            ],
          ),
          content: Text(
            t?.deleteDataConfirmContent ?? 'すべての記録と設定を完全に削除します。\n\nこの操作は取り消すことができません。\n本当に削除しますか？',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t?.btnCancel ?? 'キャンセル',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllData();
              },
              child: Text(
                t?.deleteDataConfirmButton ?? '削除する',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllData() async {
    try {
      // データを削除
      await DataStorage.clearAllData();
      
      // 設定をリセット
      setState(() {
        _targetCalories = null;
        _notificationsEnabled = false;
        _syncWeight = false;
        _syncSteps = false;
        _syncCalories = false;
      });

      // 成功メッセージを表示
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t?.deleteDataSuccessMessage ?? 'すべてのデータを削除しました。アプリが初期化されました。'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // エラーメッセージを表示
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t?.deleteDataErrorMessage ?? 'データ削除中にエラーが発生しました'}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showDummyDataDialog() async {
    final t = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.data_usage, color: Colors.blue),
              const SizedBox(width: 10),
              Text(t?.dummyDataTitle ?? 'ダミーデータ生成'),
            ],
          ),
          content: Text(
            t?.dummyDataConfirmContent ?? '1週間分のランダムなダミーデータを生成します。\n\n既存のデータは保持されます。',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t?.btnCancel ?? 'キャンセル',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _generateDummyData();
              },
              child: Text(
                t?.generateDummyDataButton ?? '生成する',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateDummyData() async {
    try {
      // ダミーデータを生成
      await DummyDataService.generateWeekData();
      
      // 成功メッセージを表示
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t?.dummyDataSuccessMessage ?? '1週間分のダミーデータを生成しました。'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // エラーメッセージを表示
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t?.dummyDataErrorMessage ?? 'ダミーデータ生成中にエラーが発生しました'}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showShareOptions() async {
    final t = AppLocalizations.of(context);
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
              t?.shareOptionsTitle ?? '共有オプション',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.lightBlue),
              title: Text(t?.shareAllDataOption ?? '全データをCSVで共有'),
              subtitle: Text(t?.shareAllDataSubtitle ?? 'すべての記録データをCSVファイルとして共有'),
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
              title: Text(t?.sharePeriodOption ?? '期間を指定してCSV共有'),
              subtitle: Text(t?.sharePeriodSubtitle ?? '特定の期間のデータをCSVファイルとして共有'),
              onTap: () async {
                Navigator.pop(context);
                _showDateRangePicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.lightBlue),
              title: Text(t?.shareAppOption ?? 'アプリを紹介'),
              subtitle: Text(t?.shareAppSubtitle ?? 'アプリの紹介文を共有'),
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

  Future<void> _showLanguagePicker() async {
    final t = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<Locale?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(t?.language ?? 'Language', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('日本語'),
                onTap: () => Navigator.pop(ctx, const Locale('ja')),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                onTap: () => Navigator.pop(ctx, const Locale('en')),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('简体中文'),
                onTap: () => Navigator.pop(ctx, const Locale('zh')),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('한국어'),
                onTap: () => Navigator.pop(ctx, const Locale('ko')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(t?.systemDefault ?? 'System default'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    AppLocale.set(selected);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t?.settingsTitle ?? '設定',
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 目標カロリー設定
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
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
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
                    child: Row(
                      children: [
                        const Icon(Icons.track_changes, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          t?.targetCalorieTitle ?? '目標カロリー',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          '${t?.currentTargetLabel ?? '現在の目標'}: ${_targetCalories?.toInt() ?? 0} kcal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.lightBlue,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: t?.targetCalorieLabel ?? '目標カロリー',
                                  border: const OutlineInputBorder(),
                                  suffixText: 'kcal',
                                ),
                                onSubmitted: (value) {
                                  final calories = double.tryParse(value);
                                  _updateTargetCalories(calories);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                final controller = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(t?.targetCalorieSettingTitle ?? '目標カロリー設定'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: t?.targetCalorieLabel ?? '目標カロリー',
                                        suffixText: 'kcal',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(t?.btnCancel ?? 'キャンセル'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final calories = double.tryParse(controller.text);
                                          _updateTargetCalories(calories);
                                          Navigator.pop(context);
                                        },
                                        child: Text(t?.btnUpdate ?? '設定'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(t?.btnUpdate ?? '変更'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 共有機能
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
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
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
                    child: Row(
                      children: [
                        const Icon(Icons.share, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          t?.dataSharingTitle ?? 'データ共有',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                                                 ListTile(
                           leading: const Icon(Icons.share, color: Colors.lightBlue),
                           title: Text(AppLocalizations.of(context)?.shareDataTitle ?? 'データを共有'),
                           subtitle: Text(AppLocalizations.of(context)?.shareDataSubtitle ?? '記録データをCSVファイルとして共有'),
                           trailing: const Icon(Icons.arrow_forward_ios),
                           onTap: _showShareOptions,
                         ),
                         ListTile(
                           leading: const Icon(Icons.info, color: Colors.lightBlue),
                           title: Text(AppLocalizations.of(context)?.shareAppTitle ?? 'アプリを紹介'),
                           subtitle: Text(AppLocalizations.of(context)?.shareAppSubtitle ?? 'アプリの紹介文を共有'),
                           trailing: const Icon(Icons.arrow_forward_ios),
                           onTap: () async {
                             await ShareService.shareApp();
                           },
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 通知設定
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
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
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
                    child: Row(
                      children: [
                        const Icon(Icons.notifications, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.notificationSettingsTitle ?? '通知設定',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SwitchListTile(
                      title: Text(AppLocalizations.of(context)?.notificationSettingsTitle ?? '通知を有効にする'),
                      subtitle: Text(AppLocalizations.of(context)?.notificationSettingsSubtitle ?? '食事記録のリマインダー'),
                      value: _notificationsEnabled,
                      onChanged: _updateNotifications,
                      activeColor: Colors.lightBlue,
                    ),
                  ),
                ],
              ),
            ),

            // 健康データ連携設定
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
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
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
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.healthDataSyncTitle ?? '健康データ連携',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(AppLocalizations.of(context)?.healthDataSyncTitle ?? '体重データを同期'),
                          subtitle: Text(AppLocalizations.of(context)?.healthDataSyncSubtitle ?? 'HealthKit/Google Fitから体重データを取得'),
                          value: _syncWeight,
                          onChanged: (value) => _updateSyncSettings('weight', value),
                          activeColor: Colors.lightBlue,
                        ),
                        SwitchListTile(
                          title: Text(AppLocalizations.of(context)?.healthDataSyncTitle ?? '歩数データを同期'),
                          subtitle: Text(AppLocalizations.of(context)?.healthDataSyncSubtitle ?? 'HealthKit/Google Fitから歩数データを取得'),
                          value: _syncSteps,
                          onChanged: (value) => _updateSyncSettings('steps', value),
                          activeColor: Colors.lightBlue,
                        ),
                        SwitchListTile(
                          title: Text(AppLocalizations.of(context)?.healthDataSyncTitle ?? '消費カロリーを同期'),
                          subtitle: Text(AppLocalizations.of(context)?.healthDataSyncSubtitle ?? 'HealthKit/Google Fitから消費カロリーを取得'),
                          value: _syncCalories,
                          onChanged: (value) => _updateSyncSettings('calories', value),
                          activeColor: Colors.lightBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // アプリ情報
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
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
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
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.appInfoTitle ?? 'アプリ情報',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language, color: Colors.lightBlue),
                          title: Text(t?.languageSetting ?? '言語設定'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showLanguagePicker,
                        ),
                        ListTile(
                          leading: const Icon(Icons.app_settings_alt, color: Colors.lightBlue),
                          title: Text(t?.versionLabel ?? 'バージョン'),
                          subtitle: const Text('1.1.1'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description, color: Colors.lightBlue),
                          title: Text(t?.privacyPolicyLabel ?? 'プライバシーポリシー'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.help, color: Colors.lightBlue),
                          title: Text(t?.helpLabel ?? 'ヘルプ'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // データ管理
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                                            child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              t?.dataManagementTitle ?? 'データ管理',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                                                 ListTile(
                           leading: const Icon(Icons.data_usage, color: Colors.blue),
                           title: Text(
                             t?.dummyDataTitle ?? 'ダミーデータ生成',
                             style: const TextStyle(
                               color: Colors.blue,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           subtitle: Text(
                             t?.dummyDataSubtitle ?? '1週間分のランダムなダミーデータを生成します',
                             style: const TextStyle(color: Colors.blue),
                           ),
                           trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                           onTap: () => _showDummyDataDialog(),
                         ),
                         ListTile(
                           leading: const Icon(Icons.delete_forever, color: Colors.red),
                           title: Text(
                             t?.deleteAllDataTitle ?? '完全にデータを削除',
                             style: const TextStyle(
                               color: Colors.red,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           subtitle: Text(
                             t?.deleteAllDataSubtitle ?? 'すべての記録と設定を削除してアプリを初期化します',
                             style: const TextStyle(color: Colors.red),
                           ),
                           trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
                           onTap: () => _showDeleteDataDialog(context),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 