# 署名設定ガイド

## 方法1: Android Studioを使用（推奨）

### 1. Android Studioで署名設定
1. Android Studioを開く
2. プロジェクトを開く: `C:\Users\user\calorie_note_ver2`
3. **Build** → **Generate Signed Bundle / APK**
4. **APK**を選択
5. **Create new keystore**をクリック

### 2. keystore情報を入力
```
Key store path: C:\Users\user\calorie_note_ver2\android\upload-keystore.jks
Password: [安全なパスワードを設定]
Alias: upload
Validity: 10000
Certificate:
  - First and Last Name: [あなたの名前]
  - Organizational Unit: [組織単位]
  - Organization: [組織名]
  - City or Locality: [市区町村]
  - State or Province: [都道府県]
  - Country Code: JP
```

### 3. key.propertiesファイルを作成
Android Studioで署名設定が完了したら、以下のファイルを作成：

**ファイル**: `android/key.properties`
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

## 「Generate Signed Bundle」が押せない場合の解決方法

### 問題1: Android StudioでFlutterプロジェクトを正しく開いていない

#### 解決方法1: Flutterプロジェクトとして開く
1. Android Studioを起動
2. **File** → **Open** を選択
3. **Flutterプロジェクトのルートフォルダ**を選択: `C:\Users\user\calorie_note_ver2`
4. **OK**をクリック
5. Android StudioがFlutterプロジェクトとして認識するまで待つ

#### 解決方法2: Androidフォルダを直接開く
1. Android Studioを起動
2. **File** → **Open** を選択
3. **Androidフォルダ**を選択: `C:\Users\user\calorie_note_ver2\android`
4. **OK**をクリック

### 問題2: プロジェクトの同期が必要

#### 解決方法:
1. **File** → **Sync Project with Gradle Files** をクリック
2. または **File** → **Invalidate Caches and Restart** を選択
3. Android Studioを再起動

### 問題3: Flutterプラグインが無効

#### 解決方法:
1. **File** → **Settings** (Windows) または **Android Studio** → **Preferences** (Mac)
2. **Plugins** を選択
3. **Flutter** プラグインが有効になっているか確認
4. 無効の場合は有効にしてAndroid Studioを再起動

### 問題4: ビルド設定の問題

#### 解決方法:
1. **Build** → **Clean Project** を実行
2. **Build** → **Rebuild Project** を実行
3. プロジェクトを再同期

### 問題5: 代替方法で署名設定

#### 方法A: Gradleタスクを使用
1. **View** → **Tool Windows** → **Gradle** を選択
2. **Tasks** → **build** → **assembleRelease** をダブルクリック
3. 署名設定が正しく設定されていれば、署名されたAPKが生成される

#### 方法B: コマンドラインで署名
```bash
cd C:\Users\user\calorie_note_ver2
flutter build apk --release
```

### 問題6: Android Studioのバージョン問題

#### 解決方法:
1. Android Studioを最新版に更新
2. Flutterプラグインを最新版に更新
3. **File** → **Invalidate Caches and Restart** を実行

## 方法2: コマンドラインでkeystore作成

### 1. Javaのインストール
1. https://adoptium.net/ からJavaをダウンロード
2. インストール後、環境変数を設定

### 2. keystore作成コマンド
```bash
# Javaのパスを確認
java -version

# keystore作成
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 3. 対話式で情報を入力
```
Enter keystore password: [パスワードを入力]
Re-enter new password: [パスワードを再入力]
What is your first and last name?: [名前]
What is the name of your organizational unit?: [組織単位]
What is the name of your organization?: [組織名]
What is the name of your City or Locality?: [市区町村]
What is the name of your State or Province?: [都道府県]
What is the two-letter country code for this unit?: JP
Is CN=名前, OU=組織単位, O=組織名, L=市区町村, ST=都道府県, C=JP correct?: yes
```

## 方法3: オンラインツールを使用

### 1. オンラインkeystore生成
1. https://keystore-explorer.org/ にアクセス
2. 新しいkeystoreを作成
3. 必要な情報を入力
4. ファイルをダウンロード

### 2. ファイルを配置
- ダウンロードしたファイルを `android/upload-keystore.jks` として保存

## 署名設定の有効化

### 1. build.gradle.ktsの更新
```kotlin
android {
    // ... 既存の設定 ...
    
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }
            
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 2. 署名されたAPKをビルド
```bash
flutter build apk --release
```

## Android Studioでの詳細な署名設定手順

### ステップ1: Android Studioでプロジェクトを開く
1. Android Studioを起動
2. **File** → **Open** を選択
3. `C:\Users\user\calorie_note_ver2\android` フォルダを選択
4. **OK**をクリック

### ステップ2: 署名設定ウィザードを開始
1. メニューバーから **Build** → **Generate Signed Bundle / APK** を選択
2. **APK** を選択して **Next** をクリック

### ステップ3: keystoreの作成
1. **Create new keystore** をクリック
2. **Key store path** に以下を入力：
   ```
   C:\Users\user\calorie_note_ver2\android\upload-keystore.jks
   ```
3. **Password** に安全なパスワードを設定（例：`MyApp2024!`）
4. **Confirm** に同じパスワードを再入力

### ステップ4: キー情報の入力
1. **Alias** に `upload` を入力
2. **Password** にキーパスワードを設定（keystoreパスワードと同じでも可）
3. **Confirm** に同じパスワードを再入力
4. **Validity (years)** に `10000` を入力

### ステップ5: 証明書情報の入力
```
First and Last Name: [あなたの名前]
Organizational Unit: [組織単位、例：Development]
Organization: [組織名、例：My Company]
City or Locality: [市区町村、例：Tokyo]
State or Province: [都道府県、例：Tokyo]
Country Code: JP
```

### ステップ6: 設定の確認
1. 入力した情報を確認
2. **OK** をクリック
3. **Next** をクリック

### ステップ7: ビルド設定
1. **release** ビルドタイプを選択
2. **V1 (Jar Signature)** と **V2 (Full APK Signature)** の両方にチェック
3. **Finish** をクリック

### ステップ8: key.propertiesファイルの作成
署名設定が完了したら、以下のファイルを作成：

**ファイル**: `android/key.properties`
```properties
storePassword=MyApp2024!
keyPassword=MyApp2024!
keyAlias=upload
storeFile=upload-keystore.jks
```

### ステップ9: build.gradle.ktsの更新確認
`android/app/build.gradle.kts` ファイルに署名設定が正しく追加されていることを確認：

```kotlin
import java.util.Properties
import java.io.FileInputStream

android {
    // ... 既存の設定 ...
    
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }
            
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

## 署名されたAPKのビルドとテスト

### 1. Flutterで署名されたAPKをビルド
```bash
cd C:\Users\user\calorie_note_ver2
flutter build apk --release
```

### 2. ビルド結果の確認
- ビルドが成功すると、以下のパスにAPKが生成されます：
  ```
  C:\Users\user\calorie_note_ver2\build\app\outputs\flutter-apk\app-release.apk
  ```

### 3. APKの署名確認
```bash
# APKの署名を確認
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk
```

## 注意事項

### セキュリティ
- keystoreファイルは安全に保管
- パスワードは忘れないように記録
- バックアップを取る
- `key.properties`ファイルはGitにコミットしない（.gitignoreに追加）

### Google Play Store
- 同じkeystoreで署名したAPKのみアップロード可能
- keystoreを紛失すると、アプリの更新ができなくなる
- 初回アップロード後はkeystoreを変更できない

## トラブルシューティング

### Javaが見つからない場合
1. Javaをインストール
2. 環境変数PATHにJavaのbinディレクトリを追加
3. コマンドプロンプトを再起動

### 署名エラーが発生する場合
1. keystoreファイルのパスを確認
2. key.propertiesファイルの内容を確認
3. パスワードが正しいか確認
4. build.gradle.ktsの署名設定を確認

### Android Studioで署名設定が見つからない場合
1. **Build** → **Generate Signed Bundle / APK** の代わりに
2. **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)** を選択
3. または **Gradle** タブから **Tasks** → **build** → **assembleRelease** を実行

### Flutterビルドエラーが発生する場合
1. Flutterのキャッシュをクリア：
   ```bash
   flutter clean
   flutter pub get
   ```
2. Android Studioを再起動
3. プロジェクトを再読み込み

## 追加のセキュリティ設定

### .gitignoreに追加
```
# Keystore files
*.jks
*.keystore
key.properties
```

### パスワード管理
- パスワードは安全な場所に保管
- パスワードマネージャーの使用を推奨
- チーム開発の場合は共有方法を決める
