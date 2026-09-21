import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    required this.child,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.02),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.60),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
