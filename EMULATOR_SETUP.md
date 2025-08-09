# Android エミュレータ セットアップガイド

## 🚀 エミュレータ作成手順

### 1. Android Studio を起動
- Android Studio を開く
- プロジェクトを開く（既存のプロジェクトまたは新規作成）

### 2. AVD Manager を開く
- **Tools** → **AVD Manager** を選択
- または **Tools** → **Device Manager** を選択

### 3. 新しいエミュレータを作成

#### 3.1 「Create Virtual Device」をクリック
- AVD Manager で「Create Virtual Device」ボタンをクリック

#### 3.2 デバイスを選択
推奨設定：
- **Category**: Phone
- **Device**: Pixel 7 (または Pixel 6)
- **Screen Size**: 6.3 inch (1080 x 2400)
- **Resolution**: 1080 x 2400

#### 3.3 システムイメージを選択
推奨設定：
- **API Level**: API 36 (Android 16.0)
- **ABI**: x86_64
- **Target**: Android 16.0 (Google APIs)

#### 3.4 エミュレータの設定
- **AVD Name**: `Pixel_7_API_36` (任意の名前)
- **Startup orientation**: Portrait
- **Graphics**: Hardware - GLES 2.0
- **Multi-core CPU**: 4 cores
- **RAM**: 2048 MB
- **VM heap**: 256 MB
- **Internal Storage**: 2048 MB
- **SD card**: 512 MB

### 4. エミュレータを起動
- 作成したエミュレータの「Play」ボタンをクリック
- 初回起動は時間がかかります（5-10分程度）

## 📱 推奨エミュレータ設定

### 高解像度エミュレータ（スクリーンショット用）
```
デバイス: Pixel 7 Pro
解像度: 1440 x 3120
API Level: 36
RAM: 4096 MB
```

### 標準エミュレータ（開発用）
```
デバイス: Pixel 7
解像度: 1080 x 2400
API Level: 36
RAM: 2048 MB
```

## 🔧 トラブルシューティング

### エミュレータが起動しない場合
1. **BIOS設定の確認**
   - Virtualization Technology (VT-x) が有効になっているか確認
   - BIOS設定で「Intel VT-x」または「AMD-V」を有効化

2. **Windows機能の確認**
   - Windows機能で「Hyper-V」が有効になっているか確認
   - コントロールパネル → プログラム → Windows機能の有効化または無効化

3. **Android Studio の再起動**
   - Android Studio を完全に終了して再起動

### パフォーマンスが悪い場合
1. **グラフィック設定の変更**
   - AVD Manager でエミュレータを編集
   - Graphics を「Software - GLES 2.0」に変更

2. **メモリ設定の調整**
   - RAM を 4096 MB に増加
   - VM heap を 512 MB に増加

## 📋 セットアップチェックリスト

### エミュレータ作成
- [ ] Android Studio を起動
- [ ] AVD Manager を開く
- [ ] 新しいエミュレータを作成
- [ ] デバイスを選択（Pixel 7）
- [ ] システムイメージを選択（API 36）
- [ ] エミュレータ設定を確認
- [ ] エミュレータを起動

### 動作確認
- [ ] エミュレータが正常に起動
- [ ] ホーム画面が表示される
- [ ] アプリのインストールが可能
- [ ] スクリーンショット撮影が可能

### Flutter との連携
- [ ] `flutter devices` でエミュレータが認識される
- [ ] `flutter run` でアプリが起動する
- [ ] ホットリロードが動作する

## 🎯 次のステップ

1. **エミュレータの作成**
   - 上記の手順に従ってエミュレータを作成

2. **アプリの起動**
   ```bash
   flutter run
   ```

3. **スクリーンショットの撮影**
   - エミュレータでアプリを起動
   - 各画面でスクリーンショットを撮影

4. **画像の品質確認**
   - 高解像度で撮影されているか確認
   - テキストの可読性を確認

## 📞 サポート

### よくある問題
1. **エミュレータが起動しない**
   - BIOS設定で仮想化を有効化
   - Windows機能でHyper-Vを有効化

2. **パフォーマンスが悪い**
   - グラフィック設定を「Software」に変更
   - メモリ設定を増加

3. **Flutterがエミュレータを認識しない**
   - Android Studio を再起動
   - `flutter doctor` で環境を確認

### 参考リンク
- [Android Studio 公式ドキュメント](https://developer.android.com/studio)
- [Flutter エミュレータ設定](https://flutter.dev/docs/get-started/install/windows)
- [AVD Manager ガイド](https://developer.android.com/studio/run/managing-avds)
