#!/usr/bin/env python3
"""
1024x1024のアイコンを512x512にリサイズするスクリプト
"""

import os
import sys

def resize_to_512():
    """アイコンを512x512にリサイズ"""
    try:
        # PILライブラリをインポート
        try:
            from PIL import Image
        except ImportError:
            print("PILライブラリがインストールされていません")
            print("pip install Pillow を実行してください")
            return False
        
        # 元のアイコンファイル
        source_file = "assets/icon/app_icon.png"
        target_file = "assets/icon/app_icon_512x512_final.png"
        
        if not os.path.exists(source_file):
            print(f"エラー: {source_file} が見つかりません")
            return False
        
        # 画像を開く
        with Image.open(source_file) as img:
            print(f"元のサイズ: {img.size}")
            
            # RGBAモードに変換（透明度を保持）
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # 512x512にリサイズ（高品質なリサンプリング）
            resized_img = img.resize((512, 512), Image.Resampling.LANCZOS)
            
            # 保存
            resized_img.save(target_file, 'PNG', optimize=True)
            
            print(f"リサイズ完了: 512x512")
            print(f"保存先: {target_file}")
            
            # ファイルサイズを確認
            file_size = os.path.getsize(target_file) / 1024  # KB
            print(f"ファイルサイズ: {file_size:.1f}KB")
            
            return True
            
    except Exception as e:
        print(f"エラー: {e}")
        return False

def main():
    print("アイコンを512x512にリサイズ中...")
    
    if resize_to_512():
        print("リサイズが正常に完了しました")
        print("Google Play Store用: assets/icon/app_icon_512x512_final.png")
    else:
        print("リサイズに失敗しました")

if __name__ == "__main__":
    main()
