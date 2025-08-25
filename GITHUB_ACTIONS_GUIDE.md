# GitHub Actionsワークフロー実行ガイド

## ✅ はじめに（前提条件）
- GitHub リポジトリを用意（このプロジェクトを push 済み）
- Apple Developer Program 登録済み（後述の署名が必要な場合）
- 本リポジトリには `/.github/workflows/ios-build.yml` が追加済み

---

## 🧭 ステップバイステップ手順（最短ルート）

### 1) リポジトリへ変更を push（自動実行のトリガー）
```bash
git add .
git commit -m "Trigger iOS build"
git push origin main
```
- この push により、`ios-build.yml` が自動実行されます（`on.push`）。

### 2) 手動で実行する場合（workflow_dispatch）
1. GitHub のリポジトリページへアクセス
2. Actions タブ → 左の「iOS Build」を選択
3. 右上の「Run workflow」→ Branch に `main` を選び「Run workflow」

### 3) 実行状況を確認
- Actions タブで該当の Run を開く
- ステータス色
  - 🟡 実行中 / 🟢 成功 / 🔴 失敗
- 失敗したら該当ステップのログを開き、エラー内容を確認

### 4) 成果物（Artifact）のダウンロード
- Run 完了後、画面下部の「Artifacts」から `ios-build` をダウンロード
- ここに IPA が出力されます（署名設定が完了している場合）

---

## 🔐 署名の設定（必要な場合：TestFlight/App Store 用）
iOS の IPA を配布用にエクスポートするには署名が必要です。代表的な 2 方式を示します。

### 方式A：自動署名（Xcode 自動）
- Apple ID で作成されたチームの「自動署名」を使います
- CI（GitHub Actions）では証明書/プロビジョニングを Secrets に保存し、`xcodebuild` または fastlane で利用します
- 必要な GitHub Secrets（例）
  - `APPLE_ID` / `APPLE_PASSWORD`（App 用パスワード推奨）
  - `CERTIFICATE_P12_BASE64`（配布証明書の p12 を Base64 化）
  - `P12_PASSWORD`
  - `PROVISIONING_PROFILE_BASE64`（プロビジョニングプロファイルを Base64 化）

### 方式B：App Store Connect API Key + fastlane（推奨）
- App Store Connect の API キー（Issuer ID / Key ID / .p8）を Secrets に保存
- fastlane/pilot で TestFlight へアップロード
- 必要な GitHub Secrets（例）
  - `ASC_API_KEY_ID`（Key ID）
  - `ASC_API_ISSUER_ID`（Issuer ID）
  - `ASC_API_KEY_P8`（.p8 の中身をそのまま保存）

> 署名の具体的な導入はチーム/要件により異なります。まずはワークフローのビルドが通ることを確認し、その後 TestFlight アップロードの自動化を追加してください。

---

## 🧪 トラブルシューティング（よくあるエラー）
- Flutter バージョン差異: `subosito/flutter-action@v2` の `flutter-version` をプロジェクトと合わせる
- Pod 周りエラー: `ruby/setup-ruby` を追加し `pod repo update && pod install` を実行
- 署名エラー: 証明書/プロビジョニング/Bundle ID/Team の整合性を確認

---

## 🔍 実行されるステップ（概要）
```yaml
steps:
- Checkout code          # コード取得
- Setup Flutter          # Flutter セットアップ
- Install dependencies   # 依存関係インストール
- Analyze code           # コード解析
- Run tests              # テスト実行
- Build iOS              # iOS ビルド（必要に応じて --no-codesign）
- Build IPA              # 署名設定があれば IPA 作成
- Upload artifacts       # IPA/ログの保存
```

---

以下は詳細ガイドです（変更なし）。

## 🚀 ワークフロー実行方法

### **1. 自動実行（推奨）**

#### A. プッシュによる自動実行
```bash
# コードを変更してプッシュ
git add .
git commit -m "Trigger iOS build"
git push origin main
```

#### B. 実行条件
- `main`ブランチへのプッシュ
- `main`ブランチへのプルリクエスト
- 手動実行（workflow_dispatch）

### **2. 手動実行**

#### A. GitHubウェブサイトから
1. **GitHubリポジトリページにアクセス**
2. **Actionsタブをクリック**
3. **左側のワークフロー一覧から「iOS Build」を選択**
4. **「Run workflow」ボタンをクリック**
5. **ブランチを選択**（通常は`main`）
6. **「Run workflow」で実行開始**

#### B. 実行画面の例
```
Actions > iOS Build > Run workflow
├── Branch: main
├── Run workflow
└── Cancel
```

### **3. 実行状況の確認**

#### A. ワークフロー一覧
- **🟡 黄色**: 実行中
- **🟢 緑色**: 成功
- **🔴 赤色**: 失敗
- **⚪ 灰色**: 待機中

#### B. 詳細ログの確認
1. **ワークフロー名をクリック**
2. **実行IDをクリック**
3. **各ステップのログを確認**

### **4. 実行ステップの詳細**

#### A. 実行されるステップ
```yaml
steps:
- Checkout code          # コードのチェックアウト
- Setup Flutter          # Flutter環境のセットアップ
- Install dependencies   # 依存関係のインストール
- Analyze code          # コード分析
- Run tests             # テスト実行
- Build iOS             # iOS版ビルド
- Build IPA             # IPAファイル作成
- Upload artifacts      # 成果物のアップロード
```

#### B. 実行時間
- **全体**: 約10-15分
- **Flutter環境セットアップ**: 2-3分
- **依存関係インストール**: 1-2分
- **iOSビルド**: 5-8分
- **IPA作成**: 1-2分

### **5. 成果物の取得**

#### A. 生成されるファイル
- **IPAファイル**: `build/ios/ipa/*.ipa`
- **ビルドログ**: `build/`フォルダ全体

#### B. ダウンロード方法
1. **ワークフロー実行完了後**
2. **「Artifacts」セクションを確認**
3. **「ios-build」をクリック**
4. **IPAファイルをダウンロード**

### **6. トラブルシューティング**

#### A. よくある問題
1. **Flutterバージョンの不一致**
   - 解決策: ワークフローファイルのFlutterバージョンを確認

2. **依存関係エラー**
   - 解決策: `pubspec.yaml`の依存関係を確認

3. **iOSビルドエラー**
   - 解決策: iOS固有の設定を確認

#### B. ログの確認方法
1. **失敗したステップをクリック**
2. **詳細ログを確認**
3. **エラーメッセージを分析**

### **7. ワークフローのカスタマイズ**

#### A. 実行条件の変更
```yaml
on:
  push:
    branches: [ main, develop ]  # 複数ブランチで実行
  schedule:
    - cron: '0 0 * * *'         # 毎日実行
```

#### B. 環境変数の追加
```yaml
env:
  FLUTTER_VERSION: '3.8.1'
  BUILD_NUMBER: ${{ github.run_number }}
```

### **8. 実行履歴の管理**

#### A. 実行履歴の確認
- **Actionsタブ**で過去の実行履歴を確認
- **成功/失敗の統計**を表示

#### B. 成果物の保持期間
- **IPAファイル**: 30日間
- **ビルドログ**: 7日間

## 📱 次のステップ

### **1. ワークフロー実行後**
1. **IPAファイルのダウンロード**
2. **App Store Connectにアップロード**
3. **TestFlightテスト開始**

### **2. 継続的インテグレーション**
- **自動テスト**: プッシュ時にテスト実行
- **自動ビルド**: プッシュ時にビルド実行
- **自動デプロイ**: 成功時に自動デプロイ

---

**最終更新**: 2025年08月
**ステータス**: ワークフロー設定完了 → 実行手順整備済み
