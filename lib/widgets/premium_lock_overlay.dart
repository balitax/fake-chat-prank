import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class PremiumLockOverlay extends StatelessWidget {
  final bool isLocked;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onUnlocked;

  const PremiumLockOverlay({
    super.key,
    required this.isLocked,
    required this.child,
    this.onTap,
    this.onUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLocked)
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap ?? () => _showPremiumDialog(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.amber[200],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showPremiumDialog(BuildContext context) {
    final adService = AdService();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber[600], size: 28),
            const SizedBox(width: 8),
            const Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Watch a short ad to unlock all premium features for 6 hours:',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.palette_outlined, 'Premium chat themes'),
            _buildFeatureRow(Icons.group_outlined, 'Group chat mode'),
            _buildFeatureRow(Icons.hide_image_outlined, 'Remove watermark'),
            _buildFeatureRow(Icons.photo_library_outlined, 'Custom backgrounds'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('LATER'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _watchRewardedAd(context, adService);
            },
            icon: const Icon(Icons.play_circle_outline, size: 20),
            label: const Text('Watch Ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.amber[700]),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _watchRewardedAd(BuildContext context, AdService adService) {
    adService.showRewardedAd(
      onRewarded: () async {
        await adService.unlockPremium();
        onUnlocked?.call();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Premium unlocked for 6 hours!'),
                ],
              ),
              backgroundColor: const Color(0xFF00A884),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
    ).then((shown) {
      if (!shown && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ad not ready yet. Please try again.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }
}
