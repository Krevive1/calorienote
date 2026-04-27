# slot-reset-guide

初心者向けの「スロット朝一リセット狙い」情報サイトです。  
GitHub Pages（`main` ブランチの `/root`）で公開する静的サイト構成です。

## サイト概要

- 朝一リセット狙いの基本を初心者向けに解説
- 免責事項・プライバシーポリシーを含む最小構成
- HTML/CSSのみで運用できる軽量サイト

## ファイル構成（リポジトリ直下）

- `index.html`（トップページ）
- `beginner.html`（初心者向け解説）
- `disclaimer.html`（免責事項）
- `privacy.html`（プライバシーポリシー）
- `styles.css`（共通スタイル）

> `starter_site` フォルダは使用せず、上記ファイルを直下配置で運用します。

## GitHub Pages 公開手順

1. このリポジトリの `main` ブランチにファイルを push
2. GitHubの **Settings → Pages** を開く
3. **Source: Deploy from a branch** を選択
4. **Branch: main / (root)** を選択して保存
5. 数分待って公開完了を確認

## 公開URL確認方法

- 本番URL: `https://krevive1.github.io/slot-reset-guide/`
- 上記URLにアクセスして、トップページ（`index.html`）が直接表示されればOK
- もし更新が反映されない場合はブラウザをハードリロード（Shift+Reload）

## ローカル確認（任意）

```bash
python3 -m http.server 8000
```

`http://localhost:8000/` を開いて表示を確認してください。
