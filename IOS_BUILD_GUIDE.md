# iOS版ビルドガイド

## 🚨 現在の状況
- **環境**: Windows
- **問題**: iOSビルドにはmacOS + Xcodeが必要
- **Android版**: ビルド完了 ✅

## 🔧 iOS版ビルドの解決策

### 1. **macOS環境でのビルド**（推奨）

#### A. 物理的なMacマシン
```bash
# 1. macOS + Xcodeをインストール
# 2. Flutter SDKをインストール
# 3. プロジェクトをクローン
git clone [your-repo]
cd calorie_note_ver2

# 4. 依存関係の更新
flutter pub get

# 5. iOS版のビルド
flutter build ios --release

# 6. IPAファイルの作成
flutter build ipa --release
```

#### B. クラウドベースのMacサービス

##### GitHub Actions（推奨）
```yaml
# .github/workflows/ios-build.yml
name: iOS Build
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
    - run: flutter pub get
    - run: flutter build ios --release
    - run: flutter build ipa --release
    - uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/ipa/*.ipa
```

##### Codemagic
- 無料プランでmacOSビルド可能
- Flutterプロジェクトの自動認識
- App Store Connectへの自動アップロード

##### Bitrise
- macOS環境でのビルド
- 自動化ワークフロー
- TestFlightへの自動デプロイ

### 2. **現在できる準備作業**（Windows環境）

#### A. プロジェクトの準備
```bash
# 1. 依存関係の確認
flutter pub get

# 2. コードの最終確認
flutter analyze

# 3. テストの実行
flutter test

# 4. アセットの準備
# - アイコン（1024x1024）
# - スクリーンショット
# - プライバシーポリシー
```

#### B. App Store Connect準備
- [ ] アプリ情報の入力
- [ ] スクリーンショットの準備
- [ ] 説明文の作成
- [ ] キーワードの設定

### 3. **具体的なアクションプラン**

#### **即座に実行**（Windows環境）
1. **プロジェクトの最終確認**
   ```bash
   flutter analyze
   flutter test
   ```

2. **アセットの準備**
   - アプリアイコン（1024x1024）
   - スクリーンショット（各言語・各サイズ）
   - プライバシーポリシー

3. **App Store Connect登録**
   - アプリ情報の入力
   - スクリーンショットのアップロード

#### **macOS環境での実行**
1. **環境セットアップ**
   - macOS + Xcode
   - Flutter SDK
   - プロジェクトのクローン

2. **iOS版ビルド**
   ```bash
   flutter build ios --release
   flutter build ipa --release
   ```

3. **TestFlightアップロード**
   - App Store Connectにアップロード
   - TestFlightテスト開始

## 📱 ビルド後の手順

### 1. **TestFlightテスト**
- 内部テスト開始
- 外部テスト開始
- フィードバック収集

### 2. **App Store審査申請**
- 最終ビルドのアップロード
- 審査申請の提出
- 審査結果の待機

### 3. **リリース**
- 審査通過後のリリース
- 監視・分析の開始

## 🔍 トラブルシューティング

### よくある問題
1. **署名エラー**
   - 証明書の設定確認
   - プロビジョニングプロファイルの確認

2. **依存関係エラー**
   - `flutter pub get`の実行
   - バージョンの互換性確認

3. **ビルドエラー**
   - Xcodeのバージョン確認
   - iOS SDKのバージョン確認

## 📞 サポート

### 参考資料
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)

### 次のステップ
1. **macOS環境の準備**
2. **iOS版ビルドの実行**
3. **TestFlightテストの開始**
4. **App Store審査申請**

---

**最終更新**: 2024年12月
**ステータス**: Android版ビルド完了 → iOS版ビルド準備中
