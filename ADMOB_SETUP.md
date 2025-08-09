# AdMob設定ガイド

## 📱 アプリ登録

### 1. アプリを追加
1. AdMobダッシュボード → 「アプリ」→「アプリを追加」
2. プラットフォーム: **Android**
3. アプリ名: **カロリーノート**
4. パッケージ名: `com.example.calorie_note_ver2`

### 2. アプリIDを取得
- アプリ登録後、**アプリID**が表示されます
- 例: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`

## 🎯 広告ユニット作成

### 1. バナー広告
1. アプリ選択 → 「広告ユニット」→「広告ユニットを作成」
2. 広告形式: **バナー**
3. 広告ユニット名: `Banner Ad`
4. **広告ユニットID**をコピー（例: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy`）

### 2. インタースティシャル広告
1. 「広告ユニットを作成」
2. 広告形式: **インタースティシャル**
3. 広告ユニット名: `Interstitial Ad`
4. **広告ユニットID**をコピー

### 3. リワード広告
1. 「広告ユニットを作成」
2. 広告形式: **リワード**
3. 広告ユニット名: `Rewarded Ad`
4. **広告ユニットID**をコピー

## 🔧 コード更新

### 1. AndroidManifest.xml更新
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_APP_ID_HERE"/>
```

### 2. ad_service.dart更新
```dart
static String get bannerAdUnitId {
  return 'YOUR_BANNER_AD_UNIT_ID';
}

static String get interstitialAdUnitId {
  return 'YOUR_INTERSTITIAL_AD_UNIT_ID';
}

static String get rewardedAdUnitId {
  return 'YOUR_REWARDED_AD_UNIT_ID';
}
```

## 📊 広告収益の最適化

### 推奨設定
- **バナー広告**: ホーム画面下部、記録一覧画面
- **インタースティシャル広告**: 画面遷移時（1日3-5回程度）
- **リワード広告**: 特別機能解除時

### ユーザーエクスペリエンス
- 過度な広告表示を避ける
- ユーザーの操作を妨げない配置
- 広告表示頻度の調整機能を提供

## ⚠️ 注意事項

1. **テスト期間**: 本番広告は承認まで時間がかかります
2. **ポリシー遵守**: AdMobポリシーに準拠した広告配置
3. **収益監視**: 定期的に収益レポートを確認
4. **ユーザーフィードバック**: 広告に関するユーザー意見を収集

## 🚀 次のステップ

1. 上記の広告ユニットIDを取得
2. コードを更新
3. テストビルドで動作確認
4. 本番リリース準備
