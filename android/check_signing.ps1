# 署名設定確認スクリプト
Write-Host "=== 署名設定確認 ===" -ForegroundColor Green

# key.propertiesファイルの存在確認
$keyPropertiesPath = "key.properties"
if (Test-Path $keyPropertiesPath) {
    Write-Host "✓ key.propertiesファイルが見つかりました" -ForegroundColor Green
    Get-Content $keyPropertiesPath | ForEach-Object {
        if ($_ -match "YOUR_") {
            Write-Host "⚠ $_ (設定が必要)" -ForegroundColor Yellow
        } else {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "✗ key.propertiesファイルが見つかりません" -ForegroundColor Red
}

# keystoreファイルの存在確認
$keystoreFiles = @("upload-keystore.jks", "*.jks", "*.keystore")
$foundKeystore = $false

foreach ($pattern in $keystoreFiles) {
    $files = Get-ChildItem -Path "." -Filter $pattern -ErrorAction SilentlyContinue
    if ($files) {
        Write-Host "✓ Keystoreファイルが見つかりました: $($files[0].Name)" -ForegroundColor Green
        $foundKeystore = $true
        break
    }
}

if (-not $foundKeystore) {
    Write-Host "✗ Keystoreファイルが見つかりません" -ForegroundColor Red
    Write-Host "Android Studioで署名設定を行ってください" -ForegroundColor Yellow
}

# build.gradle.ktsの署名設定確認
$buildGradlePath = "app\build.gradle.kts"
if (Test-Path $buildGradlePath) {
    $content = Get-Content $buildGradlePath -Raw
    if ($content -match "signingConfigs") {
        Write-Host "✓ build.gradle.ktsに署名設定が含まれています" -ForegroundColor Green
    } else {
        Write-Host "✗ build.gradle.ktsに署名設定が含まれていません" -ForegroundColor Red
    }
} else {
    Write-Host "✗ build.gradle.ktsファイルが見つかりません" -ForegroundColor Red
}

Write-Host "`n=== 次のステップ ===" -ForegroundColor Cyan
Write-Host "1. Android Studioで署名設定を行う" -ForegroundColor White
Write-Host "2. key.propertiesファイルのパスワードを設定" -ForegroundColor White
Write-Host "3. flutter build apk --release でビルド" -ForegroundColor White
