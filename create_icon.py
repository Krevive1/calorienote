#!/usr/bin/env python3
"""
アプリアイコン生成スクリプト
SVGファイルからPNGファイルを生成します
"""

import os
import sys
from pathlib import Path

def create_icon():
    """アプリアイコンを生成する"""
    try:
        # 必要なライブラリをインポート
        import cairosvg
        
        # 入力ファイルと出力ディレクトリ
        svg_file = "assets/icon/app_icon.svg"
        output_dir = "assets/icon"
        
        # 出力ディレクトリが存在しない場合は作成
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        # PNGファイルを生成
        output_file = os.path.join(output_dir, "app_icon.png")
        
        # SVGからPNGに変換（1024x1024サイズ）
        cairosvg.svg2png(url=svg_file, write_to=output_file, output_width=1024, output_height=1024)
        
        print(f"✅ アプリアイコンが生成されました: {output_file}")
        print("📱 次に 'flutter pub run flutter_launcher_icons:main' を実行してください")
        
    except ImportError:
        print("❌ cairosvgライブラリがインストールされていません")
        print("📦 インストール方法: pip install cairosvg")
        print("💡 または、手動でSVGファイルをPNGに変換してください")
        
    except FileNotFoundError:
        print("❌ SVGファイルが見つかりません: assets/icon/app_icon.svg")
        print("📁 ファイルが存在することを確認してください")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")

if __name__ == "__main__":
    create_icon() 