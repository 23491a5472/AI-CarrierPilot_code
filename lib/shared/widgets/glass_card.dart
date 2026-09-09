import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_radius.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final BorderRadiusGeometry? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.blur = 20,
    this.opacity = 0.6,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.card;
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.glass,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
