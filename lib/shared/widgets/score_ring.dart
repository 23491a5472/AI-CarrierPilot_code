import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Clean circular score visualization ring.
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
    this.strokeWidth = 10.0,
    this.color,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? AppColors.primary;
    final displayScore = (score * 100).toInt();
    final fontSize = size >= 120 ? 32.0 : (size >= 80 ? 20.0 : 12.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            strokeCap: StrokeCap.round,
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutCubic),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$displayScore%',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                if (label.isNotEmpty && size >= 100) ...[
                  const SizedBox(height: 4),
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
