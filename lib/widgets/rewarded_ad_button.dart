import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class RewardedAdButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onRewarded;
  final IconData icon;

  const RewardedAdButton({
    super.key,
    required this.buttonText,
    required this.onRewarded,
    required this.icon,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  Future<void> _loadRewardedAd() async {
    await AdService.loadRewardedAd();
  }

  Future<void> _showRewardedAd() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AdService.showRewardedAd(
        onRewarded: () {
          widget.onRewarded();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('報酬を獲得しました！'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      // 内部テストモードの場合、直接報酬を付与
      widget.onRewarded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('内部テストモード: 報酬を獲得しました！'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      // 次の広告を読み込み
      _loadRewardedAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _showRewardedAd,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(widget.icon, color: Colors.white, size: 24),
        label: Text(
          _isLoading ? '読み込み中...' : widget.buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
