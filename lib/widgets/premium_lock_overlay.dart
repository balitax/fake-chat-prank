import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class PremiumLockOverlay extends StatefulWidget {
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
  State<PremiumLockOverlay> createState() => _PremiumLockOverlayState();
}

class _PremiumLockOverlayState extends State<PremiumLockOverlay> {
  int _adsWatched = 0;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadAdsCount();
  }

  Future<void> _loadAdsCount() async {
    final count = await _adService.getAdsWatchedCount();
    if (mounted) {
      setState(() => _adsWatched = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLocked)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onTap ?? () => _showPremiumDialog(context),
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
                        const Icon(Icons.lock, color: Colors.amber, size: 16),
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
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
                Text(
                  'Watch ${AdService.adsRequiredForPremium} short ads to unlock all premium features for 6 hours:',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _adsWatched / AdService.adsRequiredForPremium,
                          backgroundColor: Colors.amber[100],
                          color: Colors.amber[700],
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_adsWatched/${AdService.adsRequiredForPremium}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(Icons.palette_outlined, 'Premium chat themes'),
                _buildFeatureRow(Icons.group_outlined, 'Group chat mode'),
                _buildFeatureRow(Icons.hide_image_outlined, 'Remove watermark'),
                _buildFeatureRow(
                  Icons.photo_library_outlined,
                  'Custom backgrounds',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('LATER'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _watchRewardedAd(context, setDialogState);
                },
                icon: const Icon(Icons.play_circle_outline, size: 20),
                label: Text(_adsWatched == 0 ? 'Watch Ad' : 'Watch Next Ad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
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

  void _watchRewardedAd(BuildContext context, StateSetter setDialogState) {
    _adService
        .showRewardedAd(
          onRewarded: () async {
            await _adService.incrementAdsWatchedCount();
            final newCount = await _adService.getAdsWatchedCount();

            if (mounted) {
              setState(() => _adsWatched = newCount);
              setDialogState(() {});
            }

            if (newCount >= AdService.adsRequiredForPremium) {
              await _adService.unlockPremium();
              if (mounted) {
                setState(() => _adsWatched = 0);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                }
              }
              widget.onUnlocked?.call();

              if (mounted && context.mounted) {
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
            } else {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ad watched! Watch ${AdService.adsRequiredForPremium - newCount} more to unlock premium.',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        )
        .then((shown) {
          if (mounted && !shown && context.mounted) {
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
