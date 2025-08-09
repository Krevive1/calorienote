# エミュレータ起動手順

## 🚀 手動でエミュレータを起動する方法

### 方法1: コマンドラインから起動

1. **Android SDK の emulator ディレクトリに移動**
   ```bash
   cd "C:\Users\user\AppData\Local\Android\sdk\emulator"
   ```

2. **利用可能なエミュレータを確認**
   ```bash
   .\emulator.exe -list-avds
   ```

3. **エミュレータを起動**
   ```bash
   .\emulator.exe -avd Medium_Phone_API_36.0
   ```

### 方法2: Android Studio から起動

1. **Android Studio を起動**
2. **Tools** → **Device Manager** を選択
3. **Medium_Phone_API_36.0** の横の「Play」ボタンをクリック

### 方法3: Flutter から起動

1. **利用可能なエミュレータを確認**
   ```bash
   flutter emulators
   ```

2. **エミュレータを起動**
   ```bash
   flutter emulators --launch Medium_Phone_API_36.0
   ```

## ⏱️ 起動時間

- **初回起動**: 5-10分程度
- **2回目以降**: 1-3分程度
- **起動完了の目印**: Android のホーム画面が表示される

## 🔍 起動確認方法

### 1. エミュレータウィンドウの確認
- エミュレータウィンドウが表示される
- Android のロゴが表示される
- ホーム画面が表示される

### 2. Flutter での確認
```bash
flutter devices
```
- エミュレータがリストに表示される

### 3. ADB での確認
```bash
adb devices
```
- エミュレータが接続されていることを確認

## 🎯 起動後の手順

### 1. アプリの起動
```bash
flutter run
```

### 2. スクリーンショットの撮影準備
- エミュレータでアプリが正常に動作することを確認
- 各画面でスクリーンショットを撮影

## 🔧 トラブルシューティング

### エミュレータが起動しない場合

1. **仮想化の確認**
   ```bash
   # Windows PowerShell で確認
   Get-ComputerInfo -Property "HyperVRequirementVirtualizationFirmwareEnabled"
   ```

2. **BIOS設定の確認**
   - Virtualization Technology (VT-x) が有効になっているか確認
   - BIOS設定で「Intel VT-x」または「AMD-V」を有効化

3. **Windows機能の確認**
   - コントロールパネル → プログラム → Windows機能の有効化または無効化
   - 「Hyper-V」が有効になっているか確認

### パフォーマンスが悪い場合

1. **グラフィック設定の変更**
   - Android Studio でエミュレータを編集
   - Graphics を「Software - GLES 2.0」に変更

2. **メモリ設定の調整**
   - RAM を 4096 MB に増加
   - VM heap を 512 MB に増加

## 📋 起動チェックリスト

- [ ] エミュレータが起動している
- [ ] Android のホーム画面が表示されている
- [ ] `flutter devices` でエミュレータが認識されている
- [ ] `flutter run` でアプリが起動する
- [ ] スクリーンショット撮影が可能

## 🎯 次のステップ

1. **エミュレータの起動**
   - 上記の方法のいずれかでエミュレータを起動

2. **アプリの起動**
   ```bash
   flutter run
   ```

3. **スクリーンショットの撮影**
   - 各画面でスクリーンショットを撮影
   - 高解像度で保存

4. **画像の品質確認**
   - テキストの可読性を確認
   - デザインの美しさを確認
