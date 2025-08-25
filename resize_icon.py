#!/usr/bin/env python3
"""
アプリアイコンを512x512ピクセルにリサイズするスクリプト
"""

import os
import sys
from PIL import Image

def resize_icon(input_path, output_path, target_size=(512, 512)):
    """アイコンを指定サイズにリサイズ"""
    try:
        # 画像を開く
        with Image.open(input_path) as img:
            print(f"元のサイズ: {img.size}")
            
            # RGBAモードに変換（透明度を保持）
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # リサイズ（高品質なリサンプリング）
            resized_img = img.resize(target_size, Image.Resampling.LANCZOS)
            
            # 保存
            resized_img.save(output_path, 'PNG', optimize=True)
            
            print(f"リサイズ完了: {target_size}")
            print(f"保存先: {output_path}")
            
            # ファイルサイズを確認
            file_size = os.path.getsize(output_path) / 1024  # KB
            print(f"ファイルサイズ: {file_size:.1f}KB")
            
            return True
            
    except Exception as e:
        print(f"エラー: {e}")
        return False

def main():
    input_file = "assets/icon/app_icon.png"
    output_file = "assets/icon/app_icon_512x512.png"
    
    if not os.path.exists(input_file):
        print(f"エラー: {input_file} が見つかりません")
        return
    
    print("アプリアイコンを512x512ピクセルにリサイズ中...")
    
    if resize_icon(input_file, output_file):
        print("リサイズが正常に完了しました")
        
        # 元のファイルをバックアップして新しいファイルに置き換え
        backup_file = "assets/icon/app_icon_backup.png"
        os.rename(input_file, backup_file)
        os.rename(output_file, input_file)
        
        print(f"元のファイルを {backup_file} にバックアップしました")
        print("新しい512x512アイコンが app_icon.png として保存されました")
    else:
        print("リサイズに失敗しました")

if __name__ == "__main__":
    main()
