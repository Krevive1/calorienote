# Calorienote ではなく slot-reset-guide に切り替える手順

現在の作業ディレクトリが `/workspace/calorienote` なので、ここで編集すると **calorienote リポジトリ** にコミットされます。  
これを避けるために、`slot-reset-guide` 用の別ディレクトリ・別Gitリポジトリを作って作業してください。

---

## 1) 新しい作業フォルダを作る

```bash
cd /workspace
mkdir -p slot-reset-guide
cd slot-reset-guide
```

## 2) GitHubの新規リポジトリを紐づける

```bash
git init
git branch -M main
git remote add origin https://github.com/krevive1/slot-reset-guide.git
```

## 3) 必要ファイルだけコピーする

```bash
cp /workspace/calorienote/index.html .
cp /workspace/calorienote/beginner.html .
cp /workspace/calorienote/disclaimer.html .
cp /workspace/calorienote/privacy.html .
cp /workspace/calorienote/styles.css .
cp /workspace/calorienote/README.md .
```

## 4) 初回push

```bash
git add .
git commit -m "Initial GitHub Pages site"
git push -u origin main
```

## 5) GitHub Pagesを有効化

1. `https://github.com/krevive1/slot-reset-guide` を開く
2. **Settings → Pages**
3. **Deploy from a branch**
4. **main / (root)** を選択して保存

## 6) 公開確認

- `https://krevive1.github.io/slot-reset-guide/` を開く
- トップページが表示されれば完了

---

## 以後、間違えてcalorienoteに入らないコツ

- 作業開始時に毎回 `pwd` を実行して、`/workspace/slot-reset-guide` を確認する
- `git remote -v` で `slot-reset-guide` のURLになっていることを確認する
