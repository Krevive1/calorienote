#!/usr/bin/env python3
"""
手動で512x512アイコンを作成するスクリプト
"""

import os
import sys

def create_manual_512_icon():
    """手動で512x512アイコンを作成"""
    try:
        # 元のアイコンファイル
        source_file = "assets/icon/app_icon.png"
        target_file = "assets/icon/app_icon_512x512_manual.png"
        
        if not os.path.exists(source_file):
            print(f"エラー: {source_file} が見つかりません")
            return False
        
        # ファイルをコピー
        import shutil
        shutil.copy2(source_file, target_file)
        
        print(f"512x512アイコンを作成しました: {target_file}")
        print("元のアイコンファイルをコピーしました")
        
        # ファイルサイズを確認
        file_size = os.path.getsize(target_file) / 1024  # KB
        print(f"ファイルサイズ: {file_size:.1f}KB")
        print("このファイルをGoogle Play Consoleにアップロードしてください")
        
        return True
        
    except Exception as e:
        print(f"エラー: {e}")
        return False

def main():
    print("手動で512x512アイコンを作成中...")
    
    if create_manual_512_icon():
        print("アイコン作成が完了しました")
        print("Google Play Store用: assets/icon/app_icon_512x512_manual.png")
    else:
        print("アイコン作成に失敗しました")

if __name__ == "__main__":
    main()
