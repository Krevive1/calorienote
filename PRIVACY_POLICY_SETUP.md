# プライバシーポリシー ホスティング設定

## 📋 現在の状況
- プライバシーポリシーファイル: `docs/privacy_policy.html` ✅ 完了
- ホスティング: 未設定

## 🌐 ホスティングオプション

### 1. GitHub Pages（推奨）
**無料で簡単に設定可能**

#### 設定手順
1. GitHubでリポジトリを作成（例: `calorienote-privacy`）
2. `docs/privacy_policy.html`をリポジトリにアップロード
3. Settings → Pages → Source: Deploy from a branch → main → /docs
4. URL: `https://[username].github.io/calorienote-privacy/privacy_policy.html`

### 2. Netlify（推奨）
**無料で高速、カスタムドメイン対応**

#### 設定手順
1. [Netlify](https://netlify.com)にサインアップ
2. `docs/privacy_policy.html`をドラッグ&ドロップ
3. URL: `https://[random-name].netlify.app/privacy_policy.html`
4. カスタムドメイン設定可能

### 3. Vercel
**無料で高速、GitHub連携**

#### 設定手順
1. [Vercel](https://vercel.com)にサインアップ
2. GitHubリポジトリと連携
3. 自動デプロイ設定

### 4. Firebase Hosting
**Googleサービスとの統合**

#### 設定手順
1. Firebase Consoleでプロジェクト作成
2. Hostingを有効化
3. `firebase deploy`でデプロイ

## 🔧 推奨設定（GitHub Pages）

### 1. リポジトリ作成
```bash
# 新しいリポジトリを作成
mkdir calorienote-privacy
cd calorienote-privacy
git init
```

### 2. ファイル配置
```bash
# プライバシーポリシーをコピー
cp ../calorie_note_ver2/docs/privacy_policy.html ./
```

### 3. GitHubにプッシュ
```bash
git add .
git commit -m "Add privacy policy"
git branch -M main
git remote add origin https://github.com/[username]/calorienote-privacy.git
git push -u origin main
```

### 4. GitHub Pages有効化
1. リポジトリのSettings → Pages
2. Source: Deploy from a branch
3. Branch: main, Folder: / (root)
4. Save

## 📝 Google Play Console用の情報

### プライバシーポリシーURL
```
https://[username].github.io/calorienote-privacy/privacy_policy.html
```

### 必要な情報
- プライバシーポリシーのURL
- データ収集の説明
- 広告に関する説明
- 連絡先情報

## ⚠️ 注意事項

### 必須項目
- プライバシーポリシーは公開アクセス可能である必要
- HTTPSでアクセス可能である必要
- アプリの実際の機能と一致している必要

### 推奨事項
- カスタムドメインの使用
- 定期的な内容更新
- 多言語対応（将来的に）

## 🚀 次のステップ

1. ホスティングサービスを選択
2. プライバシーポリシーをアップロード
3. URLを取得
4. Google Play Consoleで設定
