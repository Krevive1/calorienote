import 'package:flutter/material.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('グラフで見る')),
      body: const Center(
        child: Text('グラフ機能は今後追加予定です。'),
      ),
    );
  }
}
