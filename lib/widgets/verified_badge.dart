import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final Color? color;

  const VerifiedBadge({super.key, this.size = 14.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.verified,
        size: size,
        color:
            color ??
            const Color(
              0xFF24A1DE,
            ), // Telegram-style light blue or WhatsApp-style blue
      ),
    );
  }
}
