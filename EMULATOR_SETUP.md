# Android エミュレーター設定手順

## 📱 Google Play Console デバイス確認の代替方法

### 1. Android Studioでエミュレーターを作成

#### 手順1: Android Studioを開く
1. Android Studioを起動
2. 「More Actions」→「Virtual Device Manager」をクリック

#### 手順2: 新しいエミュレーターを作成
1. 「Create Device」をクリック
2. デバイスを選択（例: Pixel 7）
3. 「Next」をクリック

#### 手順3: システムイメージを選択
1. 「API Level 34」または「API Level 33」を選択
2. 「Google Play」マークがあるものを選択（重要）
3. 「Next」をクリック

#### 手順4: エミュレーター設定
1. エミュレーター名を入力（例: Pixel_7_API_34）
2. 「Finish」をクリック

### 2. エミュレーターを起動

#### 手順1: エミュレーターを起動
1. Virtual Device Managerで作成したエミュレーターを選択
2. 「Play」ボタンをクリック
3. エミュレーターが起動するまで待機（数分かかる場合があります）

#### 手順2: Google Play Storeにログイン
1. エミュレーターでGoogle Play Storeを開く
2. Googleアカウントでログイン
3. 必要に応じてGoogle Play Servicesを更新

### 3. Google Play Consoleアプリをインストール

#### 手順1: Google Play Consoleアプリをダウンロード
1. エミュレーターでGoogle Play Storeを開く
2. 「Google Play Console」を検索
3. アプリをインストール

#### 手順2: デバイス確認を実行
1. Google Play Consoleアプリを開く
2. 同じGoogleアカウントでログイン
3. デバイス確認の指示に従う

### 4. 代替方法（エミュレーターが使用できない場合）

#### 方法A: 友人や家族のAndroidデバイスを借りる
1. 一時的にAndroidデバイスを借りる
2. Google Play Consoleアプリをインストール
3. デバイス確認を実行
4. 確認完了後、アプリをアンインストール

#### 方法B: Googleサポートに問い合わせ
1. Google Play Consoleのヘルプページにアクセス
2. 「お問い合わせ」または「サポート」をクリック
3. デバイス確認の代替方法について問い合わせ

#### 方法C: 古いAndroidデバイスを購入
1. 中古のAndroidデバイスを購入（安価なもの）
2. デバイス確認を実行
3. 確認完了後、必要に応じて再販売

### 5. トラブルシューティング

#### エミュレーターが起動しない場合
1. **BIOS設定の確認**
   - 仮想化技術（VT-x/AMD-V）が有効になっているか確認
   - BIOSで設定を変更する必要がある場合があります

2. **Windows機能の確認**
   - Windows機能で「Hyper-V」が有効になっているか確認
   - 有効でない場合は有効化して再起動

3. **Android Studioの再インストール**
   - Android Studioを完全にアンインストール
   - 最新版を再インストール

#### Google Play Storeが動作しない場合
1. **Google Play Servicesの更新**
   - エミュレーターでGoogle Play Servicesを更新
   - 必要に応じてエミュレーターを再起動

2. **エミュレーターの再作成**
   - 異なるAPI Levelでエミュレーターを作成
   - Google Playマークがあるものを選択

### 6. 推奨設定

#### エミュレーター設定
- **RAM**: 4GB以上
- **内部ストレージ**: 8GB以上
- **API Level**: 33以上（Google Play対応）

#### システム要件
- **CPU**: 仮想化技術対応
- **RAM**: 8GB以上推奨
- **ストレージ**: 10GB以上の空き容量

## 🚀 次のステップ

1. エミュレーターでデバイス確認を完了
2. Google Play Consoleでテスト版のアップロードを開始
3. 内部テスト版 → クローズドテスト版 → オープンテスト版の順で進める

## 📞 サポート

問題が解決しない場合は、以下にお問い合わせください：
- **メール**: qgsky217@yahoo.co.jp
- **Google Play Console ヘルプ**: https://support.google.com/googleplay/android-developer
