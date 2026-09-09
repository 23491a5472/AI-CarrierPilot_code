import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ScoreRing extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final String label;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 120.0,
    this.strokeWidth = 14.0,
    this.color,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? AppColors.secondary;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score,
            strokeWidth: strokeWidth,
            backgroundColor: AppColors.warmBeige,
            valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            strokeCap: StrokeCap.round,
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(score * 100).toInt()}',
                style: size >= 120 ? AppTextStyles.scoreLarge : AppTextStyles.scoreMedium,
              ),
              if (label.isNotEmpty)
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.tag.copyWith(color: ringColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
