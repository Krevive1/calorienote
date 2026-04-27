# slot-reset-guide

初心者向けの「スロット朝一リセット狙い」情報サイトです。  
GitHub Pages で公開する前提の静的サイト（HTML/CSS）構成です。

## ファイル構成（リポジトリ直下）

- `index.html`（トップページ）
- `beginner.html`（初心者向け解説）
- `disclaimer.html`（免責事項）
- `privacy.html`（プライバシーポリシー）
- `styles.css`（共通スタイル）

## 公開URL

- 本番URL: `https://krevive1.github.io/slot-reset-guide/`

## 公開URLの確認手順

1. GitHub リポジトリの **Settings → Pages** を開く
2. Source が **Deploy from a branch** になっていることを確認
3. Branch が **main / (root)** になっていることを確認
4. ブラウザで `https://krevive1.github.io/slot-reset-guide/` にアクセス
5. トップページ（`index.html`）が直接表示されればOK

## ローカル確認（任意）

以下で簡易サーバーを立てて表示確認できます。

```bash
python3 -m http.server 8000
```

`http://localhost:8000/` を開いて表示を確認してください。
