import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.heroGradient,
        borderRadius: AppRadius.button,
        boxShadow: AppShadows.buttonPrimary,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 12)],
                  Text(text, style: AppTextStyles.buttonText),
                ],
              ),
      ),
    );
  }
}
