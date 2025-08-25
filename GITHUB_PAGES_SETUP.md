# GitHub Pages プライバシーポリシー設定手順

## 📋 手順

### 1. GitHubでリポジトリを作成

1. GitHubにログイン
2. 右上の「+」ボタン → 「New repository」をクリック
3. リポジトリ名: `calorienote-privacy`
4. Description: `Calorie Note Privacy Policy`
5. Public を選択
6. 「Create repository」をクリック

### 2. プライバシーポリシーファイルをアップロード

#### 方法A: Web上で直接アップロード
1. 作成したリポジトリのページで「uploading an existing file」をクリック
2. `docs/privacy_policy.html`をドラッグ&ドロップ
3. ファイル名を`index.html`に変更
4. 「Commit changes」をクリック

#### 方法B: コマンドラインでアップロード
```bash
# リポジトリをクローン
git clone https://github.com/[username]/calorienote-privacy.git
cd calorienote-privacy

# プライバシーポリシーをコピー
cp ../calorie_note_ver2/docs/privacy_policy.html ./index.html

# コミットしてプッシュ
git add .
git commit -m "Add privacy policy"
git push origin main
```

### 3. GitHub Pagesを有効化

1. リポジトリの「Settings」タブをクリック
2. 左サイドバーの「Pages」をクリック
3. Source: 「Deploy from a branch」を選択
4. Branch: 「main」を選択
5. Folder: 「/ (root)」を選択
6. 「Save」をクリック

### 4. URLの確認

数分後に以下のURLでアクセス可能になります：
```
https://[username].github.io/calorienote-privacy/
```

## 🔧 カスタムドメイン設定（オプション）

### 1. カスタムドメインを購入
- Google Domains、お名前.com、ムームードメインなどでドメインを購入

### 2. GitHub Pagesでカスタムドメイン設定
1. リポジトリの「Settings」→「Pages」
2. 「Custom domain」にドメインを入力（例: `privacy.calorienote.app`）
3. 「Save」をクリック
4. 「Enforce HTTPS」にチェック

### 3. DNS設定
ドメイン提供者で以下のDNSレコードを設定：
```
Type: CNAME
Name: privacy (またはサブドメイン名)
Value: [username].github.io
```

## 📝 Google Play Console用の情報

### プライバシーポリシーURL
```
https://[username].github.io/calorienote-privacy/
```

### カスタムドメイン使用時
```
https://privacy.calorienote.app/
```

## ⚠️ 注意事項

### 必須項目
- プライバシーポリシーは公開アクセス可能である必要
- HTTPSでアクセス可能である必要
- アプリの実際の機能と一致している必要

### 推奨事項
- カスタムドメインの使用（より信頼性が高い）
- 定期的な内容更新
- 多言語対応（将来的に）

## 🚀 次のステップ

1. GitHub Pagesでプライバシーポリシーを公開
2. URLを取得
3. Google Play ConsoleでプライバシーポリシーURLを設定
4. STORE_INFO.mdのURLを更新
