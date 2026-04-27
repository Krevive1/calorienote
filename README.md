# slot-reset-guide

初心者向けの「パチスロ朝一リセット」を学ぶための静的サイトです。  
GitHub Pages（`main` ブランチの `/root`）で公開する構成です。

## サイト概要

- 教育目的で、朝一リセット・リセット恩恵・注意点をやさしく解説
- 「勝てる」「稼げる」などの断定的な煽りを避ける方針
- ギャンブル依存・過度な投資を避ける注意文を掲載
- 免責事項（`disclaimer.html`）とプライバシーポリシー（`privacy.html`）を用意

## ファイル構成（リポジトリ直下）

- `index.html`
- `beginner.html`
- `disclaimer.html`
- `privacy.html`
- `styles.css`

## GitHub Pages 公開手順

1. `main` ブランチにファイルを push
2. GitHub リポジトリの **Settings → Pages** を開く
3. **Source: Deploy from a branch** を選択
4. **Branch: main / (root)** を選択して保存
5. 数分待ってデプロイ完了を確認

## 公開URL確認方法

- 公開URL: `https://krevive1.github.io/slot-reset-guide/`
- URLにアクセスし、トップページ（`index.html`）が直接表示されることを確認
- 反映されない場合はブラウザをハードリロード（Shift + Reload）

## ローカル確認（任意）

```bash
python3 -m http.server 8000
```

`http://localhost:8000/` を開いて表示確認できます。
