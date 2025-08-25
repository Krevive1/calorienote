# Google Play Store リリースチェックリスト

## 📱 アプリ準備

### ✅ 基本設定
- [x] アプリケーションIDを変更（com.example.calorie_note_ver2 → com.calorienote.app）
- [x] アプリ名を最終版に変更
- [x] バージョン番号を設定（1.0.0+1）
- [x] アプリアイコンをPNG形式で作成（1024x1024）

### ✅ 広告設定
- [x] Google AdMobアカウントを作成
- [x] 本番用のAdMobアプリIDを取得
- [x] 本番用の広告ユニットIDを取得：
  - [x] バナー広告
  - [x] インタースティシャル広告
  - [x] リワード広告
- [x] `lib/services/ad_service.dart`の広告IDを本番用に変更
- [x] `android/app/src/main/AndroidManifest.xml`のAdMobアプリIDを本番用に変更

### ✅ 署名設定
- [x] keystoreファイルを作成
- [x] `android/key.properties`ファイルを作成
- [x] `android/app/build.gradle.kts`で署名設定を有効化
- [x] 署名されたAPKをビルド

### ✅ プライバシー
- [x] プライバシーポリシーを作成・更新
- [x] プライバシーポリシーのURLを準備
- [x] データ収集・使用について明確化

## 🎨 ストア情報

### ✅ アプリ情報
- [x] アプリタイトル（80文字以内）
- [x] 短い説明（80文字以内）
- [x] 詳細説明（4000文字以内）
- [x] アプリカテゴリを選択
- [x] タグを設定

### ✅ 画像・動画
- [x] フィーチャー画像（1024x500）
- [x] スクリーンショット（16:9、4:3、9:16）
  - [x] ホーム画面
  - [x] 食事記録画面
  - [x] グラフ画面
  - [x] 設定画面
- [ ] プロモーションビデオ（オプション）

### ✅ コンテンツ評価
- [x] コンテンツ評価を設定
- [x] 対象年齢を設定

## 📋 法的要件

### ✅ プライバシー
- [x] プライバシーポリシーをアップロード
- [x] データ収集の開示
- [x] 広告に関する説明

### ✅ 広告
- [x] 広告の存在を明記
- [x] 広告収益について説明
- [x] ユーザー選択肢の提供

## 🚀 リリース準備

### ✅ 事前準備（本人確認審査中に完了可能）
- [x] 署名されたAPKをビルド
- [x] ストア情報の準備（STORE_INFO.md）
- [x] プライバシーポリシーのホスティング完了
- [x] アプリの最終動作確認

### ✅ テスト（本人確認完了後に実行）
- [x] 内部テスト版をアップロード
- [x] クローズドテスト版をアップロード
- [ ] 12人のテスターによる14日間のオプトイン
- [ ] オープンテスト版をアップロード
- [ ] フィードバックを収集・対応

### ✅ 最終確認（本人確認完了後に実行）
- [ ] アプリの動作確認
- [ ] 広告の表示確認
- [ ] プライバシーポリシーの確認
- [ ] ストア情報の確認

## 📊 リリース後

### ✅ 監視
- [ ] クラッシュレポートの確認
- [ ] ユーザーレビューの監視
- [ ] 広告収益の監視
- [ ] アプリパフォーマンスの監視

### ✅ 改善
- [ ] ユーザーフィードバックの分析
- [ ] 広告配置の最適化
- [ ] 機能改善の計画

---

## 🔧 技術的な手順

### 1. AdMob設定
```bash
# Google AdMobでアカウント作成
# https://admob.google.com/
```

### 2. 署名設定
```bash
# keystore作成
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# key.properties作成
echo "storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=../upload-keystore.jks" > android/key.properties
```

### 3. アイコン生成
```
```

### 4. プライバシーポリシーホスティング
```bash
# GitHub Pagesでの設定例
# 1. GitHubでリポジトリ作成
# 2. docs/privacy_policy.htmlをアップロード
# 3. Settings → Pages → Source: Deploy from a branch
```