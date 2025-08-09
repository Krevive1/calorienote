# アプリアイコン手動作成ガイド

## 方法1: オンラインツールを使用

### 1. Canvaを使用
1. https://www.canva.com/ にアクセス
2. 「アプリアイコン」テンプレートを選択
3. 1024x1024ピクセルで作成
4. PNG形式でダウンロード
5. `assets/icon/app_icon.png`として保存

### 2. Figmaを使用
1. https://www.figma.com/ にアクセス
2. 1024x1024のアートボードを作成
3. アイコンデザインを作成
4. PNG形式でエクスポート
5. `assets/icon/app_icon.png`として保存

## 方法2: 既存のSVGを変換

### 1. オンラインSVG to PNG変換
1. https://convertio.co/svg-png/ にアクセス
2. `assets/icon/app_icon.svg`をアップロード
3. サイズ: 1024x1024に設定
4. PNG形式でダウンロード
5. `assets/icon/app_icon.png`として保存

### 2. Inkscapeを使用（無料）
1. https://inkscape.org/ をダウンロード
2. SVGファイルを開く
3. ファイル → エクスポートPNG
4. サイズ: 1024x1024に設定
5. `assets/icon/app_icon.png`として保存

## アイコンデザインのヒント

### 推奨デザイン要素
- **背景**: 緑色系（#4CAF50）
- **アイコン**: 食事、カロリー、健康関連
- **シンプル**: 複雑すぎないデザイン
- **認識しやすい**: 小さいサイズでも分かりやすい

### カラーパレット
- メインカラー: #4CAF50（緑）
- アクセント: #FF9800（オレンジ）
- 背景: #FFFFFF（白）
- テキスト: #333333（ダークグレー）

## アイコン生成後の手順

1. `assets/icon/app_icon.png`として保存
2. 以下のコマンドを実行：
```bash
flutter pub run flutter_launcher_icons:main
```

## 注意事項

- アイコンサイズは必ず1024x1024ピクセル
- PNG形式で保存
- 透明背景を使用
- アプリアイコンは四角形（角丸可）
- ブランドガイドラインに準拠
