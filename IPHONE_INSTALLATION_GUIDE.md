# iPhoneにアプリをインストールする方法

## 📱 方法1: TestFlight（推奨）

### 前提条件
- Apple Developer Programに登録済み（年間99ドル）
- App Store Connectでアプリが登録済み
- TestFlight用のビルドがアップロード済み

### 手順
1. **iPhoneにTestFlightをインストール**
   - App Storeで「TestFlight」を検索してインストール

2. **招待メールを確認**
   - 開発者から送られる招待メールを開く
   - 「TestFlightで開く」をタップ

3. **アプリをインストール**
   - TestFlightアプリ内で「インストール」をタップ
   - 初回起動時に「信頼」を選択

### メリット
- 簡単で安全
- 自動更新
- フィードバック機能

---

## 📱 方法2: 開発者証明書（Developer Certificate）

### 前提条件
- Mac + Xcode環境
- Apple Developer Program登録
- 実機のUDID登録

### 手順
1. **Xcodeでプロジェクトを開く**
2. **実機を接続**
3. **ビルド設定を確認**
4. **実機にビルド**

### 必要なもの
- Mac
- Xcode
- Apple Developer Program
- iPhoneのUDID登録

---

## 📱 方法3: エンタープライズ配布

### 前提条件
- Apple Developer Enterprise Program（年間299ドル）
- エンタープライズ証明書

### 手順
1. **エンタープライズ証明書でビルド**
2. **配布用IPAファイルを作成**
3. **Webサイトやメールで配布**

---

## 📱 方法4: アドホック配布

### 前提条件
- Apple Developer Program
- 実機のUDID登録（最大100台）

### 手順
1. **アドホック証明書でビルド**
2. **IPAファイルを作成**
3. **iTunes経由でインストール**

---

## 🚨 現在の状況確認

### 必要な情報
1. **Apple Developer Programに登録していますか？**
   - はい → TestFlight使用可能
   - いいえ → 登録が必要

2. **Mac環境はありますか？**
   - はい → 開発者証明書使用可能
   - いいえ → TestFlightが最適

3. **App Store Connectでアプリ登録済みですか？**
   - はい → TestFlight使用可能
   - いいえ → 登録が必要

---

## 🎯 推奨手順

### 最速の方法: TestFlight
1. **Apple Developer Programに登録**（年間99ドル）
2. **App Store Connectでアプリ登録**
3. **TestFlight用ビルドをアップロード**
4. **iPhoneにTestFlightをインストール**
5. **招待メールでアプリをインストール**

### 代替案: 開発者証明書
1. **Mac + Xcode環境を準備**
2. **Apple Developer Programに登録**
3. **iPhoneのUDIDを登録**
4. **Xcodeで実機にビルド**

---

## 📋 チェックリスト

### TestFlight使用前
- [ ] Apple Developer Program登録
- [ ] App Store Connectでアプリ登録
- [ ] TestFlight用ビルド作成
- [ ] 審査申請（初回のみ）

### 開発者証明書使用前
- [ ] Mac + Xcode環境
- [ ] Apple Developer Program登録
- [ ] iPhoneのUDID登録
- [ ] 開発者証明書作成

---

## 💰 費用比較

| 方法 | 初期費用 | 年間費用 | 難易度 |
|------|----------|----------|--------|
| TestFlight | $99 | $99 | 低 |
| 開発者証明書 | $99 + Mac | $99 | 中 |
| エンタープライズ | $299 | $299 | 高 |
| アドホック | $99 | $99 | 中 |

---

## 🚀 次のステップ

1. **Apple Developer Program登録状況を確認**
2. **最適な方法を選択**
3. **必要な環境を準備**
4. **アプリをインストール**
5. **スクリーンショット撮影開始**

