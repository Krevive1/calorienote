import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/health_service.dart';
import 'data_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _mealReminderEnabled = false;
  bool _weightReminderEnabled = false;
  bool _healthSyncEnabled = false;
  bool _syncWeight = false;
  bool _syncSteps = false;
  bool _syncCalories = false;
  
  TimeOfDay _mealReminderTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _weightReminderTime = const TimeOfDay(hour: 8, minute: 0);
  List<int> _mealReminderDays = [1, 2, 3, 4, 5, 6, 7];
  List<int> _weightReminderDays = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService.getNotificationSettings();
    final healthSettings = await HealthService.getSyncSettings();
    
    setState(() {
      _mealReminderTime = _parseTime(settings['meal_reminder_time'] ?? '12:00');
      _weightReminderTime = _parseTime(settings['weight_reminder_time'] ?? '08:00');
      _mealReminderDays = (settings['meal_reminder_days'] ?? ['1', '2', '3', '4', '5', '6', '7'])
          .map((d) => int.parse(d))
          .toList();
      _weightReminderDays = (settings['weight_reminder_days'] ?? ['1', '2', '3', '4', '5', '6', '7'])
          .map((d) => int.parse(d))
          .toList();
      
      _syncWeight = healthSettings['sync_weight'] ?? false;
      _syncSteps = healthSettings['sync_steps'] ?? false;
      _syncCalories = healthSettings['sync_calories'] ?? false;
      _healthSyncEnabled = _syncWeight || _syncSteps || _syncCalories;
    });
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '設定',
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
              // 通知設定カード
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
                        const Icon(Icons.notifications, color: Colors.orange, size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          '通知設定',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 食事記録リマインダー
                    _buildReminderSection(
                      title: '食事記録リマインダー',
                      enabled: _mealReminderEnabled,
                      time: _mealReminderTime,
                      days: _mealReminderDays,
                      onEnabledChanged: (value) {
                        setState(() {
                          _mealReminderEnabled = value;
                        });
                        if (value) {
                          _scheduleMealReminder();
                        } else {
                          NotificationService.cancelAllNotifications();
                        }
                      },
                      onTimeChanged: (time) {
                        setState(() {
                          _mealReminderTime = time;
                        });
                        if (_mealReminderEnabled) {
                          _scheduleMealReminder();
                        }
                      },
                      onDaysChanged: (days) {
                        setState(() {
                          _mealReminderDays = days;
                        });
                        if (_mealReminderEnabled) {
                          _scheduleMealReminder();
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 体重記録リマインダー
                    _buildReminderSection(
                      title: '体重記録リマインダー',
                      enabled: _weightReminderEnabled,
                      time: _weightReminderTime,
                      days: _weightReminderDays,
                      onEnabledChanged: (value) {
                        setState(() {
                          _weightReminderEnabled = value;
                        });
                        if (value) {
                          _scheduleWeightReminder();
                        } else {
                          NotificationService.cancelAllNotifications();
                        }
                      },
                      onTimeChanged: (time) {
                        setState(() {
                          _weightReminderTime = time;
                        });
                        if (_weightReminderEnabled) {
                          _scheduleWeightReminder();
                        }
                      },
                      onDaysChanged: (days) {
                        setState(() {
                          _weightReminderDays = days;
                        });
                        if (_weightReminderEnabled) {
                          _scheduleWeightReminder();
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 健康データ連携カード
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
                        const Icon(Icons.favorite, color: Colors.green, size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          '健康データ連携',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 健康データ連携の有効/無効
                    SwitchListTile(
                      title: const Text('健康アプリと連携'),
                      subtitle: const Text('HealthKit / Google Fitとデータを同期'),
                      value: _healthSyncEnabled,
                      onChanged: (value) async {
                        if (value) {
                          final hasPermission = await HealthService.initialize();
                          if (hasPermission) {
                            setState(() {
                              _healthSyncEnabled = value;
                            });
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('健康データへのアクセス権限が必要です'),
                                ),
                              );
                            }
                          }
                        } else {
                          setState(() {
                            _healthSyncEnabled = value;
                            _syncWeight = false;
                            _syncSteps = false;
                            _syncCalories = false;
                          });
                          await HealthService.saveSyncSettings(
                            syncWeight: false,
                            syncSteps: false,
                            syncCalories: false,
                          );
                        }
                      },
                    ),
                    
                    if (_healthSyncEnabled) ...[
                      const SizedBox(height: 15),
                      
                      // 体重データ同期
                      CheckboxListTile(
                        title: const Text('体重データを同期'),
                        subtitle: const Text('健康アプリの体重データを自動取得'),
                        value: _syncWeight,
                        onChanged: (value) async {
                          setState(() {
                            _syncWeight = value ?? false;
                          });
                          await HealthService.saveSyncSettings(
                            syncWeight: _syncWeight,
                            syncSteps: _syncSteps,
                            syncCalories: _syncCalories,
                          );
                        },
                      ),
                      
                      // 歩数データ同期
                      CheckboxListTile(
                        title: const Text('歩数データを同期'),
                        subtitle: const Text('健康アプリの歩数データを自動取得'),
                        value: _syncSteps,
                        onChanged: (value) async {
                          setState(() {
                            _syncSteps = value ?? false;
                          });
                          await HealthService.saveSyncSettings(
                            syncWeight: _syncWeight,
                            syncSteps: _syncSteps,
                            syncCalories: _syncCalories,
                          );
                        },
                      ),
                      
                      // 消費カロリーデータ同期
                      CheckboxListTile(
                        title: const Text('消費カロリーデータを同期'),
                        subtitle: const Text('健康アプリの消費カロリーデータを自動取得'),
                        value: _syncCalories,
                        onChanged: (value) async {
                          setState(() {
                            _syncCalories = value ?? false;
                          });
                          await HealthService.saveSyncSettings(
                            syncWeight: _syncWeight,
                            syncSteps: _syncSteps,
                            syncCalories: _syncCalories,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // 手動同期ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await HealthService.syncHealthData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('健康データを同期しました'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync),
                          label: const Text('今すぐ同期'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 開発用: ダミーデータ投入ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await DataStorage.seedDummyData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('過去7日分のダミーデータを投入しました')), 
                              );
                            }
                          },
                          icon: const Icon(Icons.dataset),
                          label: const Text('過去7日分のダミーデータを投入'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 開発サポート: ダミーデータ投入カード
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
                        const Icon(Icons.dataset, color: Colors.blueGrey, size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          '開発サポート',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await DataStorage.seedDummyData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('過去7日分のダミーデータを投入しました')),
                            );
                          }
                        },
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('過去7日分のダミーデータを投入'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 31日体重推移 + 1週間食事のダミーデータ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await DataStorage.seed31DaysWeight70To66AndWeekMeals();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('31日体重(70→66kg)と直近7日分の食事ダミーデータを投入しました')),
                            );
                          }
                        },
                        icon: const Icon(Icons.timeline),
                        label: const Text('31日体重(70→66kg)＋1週間の食事を投入'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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

  Widget _buildReminderSection({
    required String title,
    required bool enabled,
    required TimeOfDay time,
    required List<int> days,
    required Function(bool) onEnabledChanged,
    required Function(TimeOfDay) onTimeChanged,
    required Function(List<int>) onDaysChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(title),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        
        if (enabled) ...[
          const SizedBox(height: 10),
          
          // 時間選択
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('通知時間'),
            subtitle: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (selectedTime != null) {
                onTimeChanged(selectedTime);
              }
            },
          ),
          
          const SizedBox(height: 10),
          
          // 曜日選択
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('通知曜日'),
            subtitle: Text(_getDaysText(days)),
            onTap: () {
              _showDaysDialog(days, onDaysChanged);
            },
          ),
        ],
      ],
    );
  }

  String _getDaysText(List<int> days) {
    const dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    if (days.length == 7) return '毎日';
    if (days.length == 5 && days.contains(1) && days.contains(2) && 
        days.contains(3) && days.contains(4) && days.contains(5)) {
      return '平日';
    }
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  void _showDaysDialog(List<int> currentDays, Function(List<int>) onChanged) {
    const dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    List<int> selectedDays = List.from(currentDays);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知曜日を選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final day = index + 1;
            return CheckboxListTile(
              title: Text(dayNames[index]),
              value: selectedDays.contains(day),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                });
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              onChanged(selectedDays);
              Navigator.pop(context);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleMealReminder() async {
    await NotificationService.scheduleMealReminder(
      time: _mealReminderTime,
      days: _mealReminderDays,
    );
  }

  Future<void> _scheduleWeightReminder() async {
    await NotificationService.scheduleWeightReminder(
      time: _weightReminderTime,
      days: _weightReminderDays,
    );
  }
} 