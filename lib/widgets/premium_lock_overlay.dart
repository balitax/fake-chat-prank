import 'package:flutter/material.dart';

class PremiumLockOverlay extends StatelessWidget {
  final bool isLocked;
  final Widget child;
  final VoidCallback? onTap;

  const PremiumLockOverlay({
    super.key,
    required this.isLocked,
    required this.child,
    this.onTap,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600]),
            const SizedBox(width: 8),
            const Text('Premium Feature'),
          ],
        ),
        content: const Text(
          'This feature is available exclusively for Premium users. '
          'Upgrade to unlock:\n\n'
          '• Premium chat themes\n'
          '• Fake group chat mode\n'
          '• Remove watermark\n'
          '• Advanced customization\n'
          '• And more!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement premium purchase flow
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
