import 'package:flutter/material.dart';
import 'home_page.dart';
import 'input_page.dart';
import 'data_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    
    // フェードインアニメーション
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // スケールアニメーション
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // フェードアウトアニメーション
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    
    // 2秒後にフェードアウト開始
    await Future.delayed(const Duration(seconds: 2));
    _fadeOutController.forward();
    
    // フェードアウト完了後（1.5秒後）に次の画面へ
    await Future.delayed(const Duration(milliseconds: 1500));
    _checkInitialSetup();
  }

  void _checkInitialSetup() async {
    final targetCalories = await DataStorage.loadDailyTargetCalories();
    
    if (mounted) {
      if (targetCalories == null) {
        // 初期設定が未完了の場合
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InputPage()),
        );
      } else {
        // 初期設定が完了している場合
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink, Colors.purple],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeController, _scaleController, _fadeOutController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: FadeTransition(
                  opacity: _fadeOutController.isAnimating ? _fadeOutAnimation : _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'カロリーノート',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'あなたの健康管理をサポート',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
