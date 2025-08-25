import 'package:flutter/material.dart';
import 'package:calorie_note/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t?.privacyPolicyTitle ?? 'プライバシーポリシー',
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t?.privacyPolicyTitle ?? 'プライバシーポリシー',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t?.privacyPolicyLastUpdated ?? '最終更新日: 2024年12月',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  t?.privacyPolicySection1Title ?? '1. 収集する情報',
                  t?.privacyPolicySection1Content ?? '本アプリは以下の情報を収集します：\n• 食事記録（食事内容、カロリー）\n• 運動記録（運動内容、消費カロリー）\n• 体重記録\n• 目標設定情報（年齢、身長、体重、目標体重等）\n• アプリの使用状況データ',
                ),
                _buildSection(
                  t?.privacyPolicySection2Title ?? '2. 情報の使用方法',
                  t?.privacyPolicySection2Content ?? '収集した情報は以下の目的で使用されます：\n• カロリー計算と目標管理\n• 進捗の可視化（グラフ表示）\n• アプリの機能向上\n• ユーザーサポート',
                ),
                _buildSection(
                  t?.privacyPolicySection3Title ?? '3. 情報の共有',
                  t?.privacyPolicySection3Content ?? '当社は以下の場合を除き、お客様の個人情報を第三者に提供いたしません：\n• お客様の同意がある場合\n• 法令に基づく場合\n• お客様の安全を保護するため必要な場合',
                ),
                _buildSection(
                  t?.privacyPolicySection4Title ?? '4. データの保存',
                  t?.privacyPolicySection4Content ?? '• データはデバイス内に安全に保存されます\n• クラウド同期機能を使用する場合、暗号化された状態で保存されます\n• アプリの削除により、保存されたデータは削除されます',
                ),
                _buildSection(
                  t?.privacyPolicySection5Title ?? '5. 広告について',
                  t?.privacyPolicySection5Content ?? '• 本アプリではGoogle AdMobを使用して広告を表示しています\n• 広告配信のために、Google AdMobがデバイス情報を収集する場合があります\n• 詳細については、Google AdMobのプライバシーポリシーをご確認ください',
                ),
                _buildSection(
                  t?.privacyPolicySection6Title ?? '6. お問い合わせ',
                  t?.privacyPolicySection6Content ?? 'プライバシーポリシーに関するお問い合わせは、以下までご連絡ください：\nEmail: qgsky217@yahoo.co.jp',
                ),
                const SizedBox(height: 20),
                Text(
                  t?.privacyPolicyNote ?? '※本プライバシーポリシーは予告なく変更される場合があります。重要な変更がある場合は、アプリ内でお知らせいたします。',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
