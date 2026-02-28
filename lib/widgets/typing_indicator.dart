import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final bool isDarkMode;
  final bool show;

  const TypingIndicator({
    super.key,
    required this.isDarkMode,
    this.show = true,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 8, right: 48, top: 2, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDarkMode 
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double offset = 0;
              final animationValue = _controller.value;
              
              // Create wave animation for each dot
              final phase = (animationValue + index * 0.2) % 1.0;
              if (phase < 0.25) {
                offset = -2;
              } else if (phase < 0.5) {
                offset = 0;
              } else if (phase < 0.75) {
                offset = 2;
              } else {
                offset = 0;
              }

              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode 
                        ? Colors.white54 
                        : Colors.black38,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
