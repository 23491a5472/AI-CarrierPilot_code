import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A reusable shimmer skeleton for loading states
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(
      duration: 1500.ms,
      color: Colors.white.withOpacity(0.6),
    );
  }
}

/// A premium full-page or section loading indicator
class LoadingState extends StatelessWidget {
  final String? message;
  
  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1000.ms, curve: Curves.easeInOut),
          
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .fade(begin: 0.5, end: 1.0, duration: 1000.ms, curve: Curves.easeInOut),
          ]
        ],
      ),
    );
  }
}
