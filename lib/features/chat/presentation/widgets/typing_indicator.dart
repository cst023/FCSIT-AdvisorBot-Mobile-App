// Animated three-dot typing indicator shown while waiting for a bot response.

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const _dotCount = 3;
  static const _dotSize = 8.0;
  static const _dotSpacing = 5.0;
  static const _animDuration = Duration(milliseconds: 400);
  static const _staggerDelay = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _dotCount,
      (i) => AnimationController(vsync: this, duration: _animDuration),
    );

    _animations = _controllers
        .map(
          (c) => Tween<double>(begin: 0, end: -6).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _dotCount; i++) {
        await Future.delayed(_staggerDelay);
        if (!mounted) return;
        _controllers[i].forward().then((_) => _controllers[i].reverse());
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          _BotAvatar(),
          const SizedBox(width: 10),
          // Bubble with animated dots
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.botBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.botBubbleBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dotCount, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: _dotSpacing / 2),
                    transform: Matrix4.translationValues(
                        0, _animations[i].value, 0),
                    width: _dotSize,
                    height: _dotSize,
                    decoration: const BoxDecoration(
                      color: AppColors.textHint,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Shared Bot Avatar ----
// Extracted as a separate widget so it can be reused in MessageBubble too.

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: const Center(
        child: Text(
          '•ᴗ•',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// Export _BotAvatar so MessageBubble can use it without duplication.
// We do this by making it a public class at the bottom of this file.
class BotAvatar extends StatelessWidget {
  const BotAvatar({super.key});

  @override
  Widget build(BuildContext context) => const _BotAvatar();
}