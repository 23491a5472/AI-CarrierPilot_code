import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const PremiumTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelText),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textLight, size: 22),
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5), fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
            enabledBorder: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
            focusedBorder: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: AppColors.secondary, width: 2)),
          ),
        ),
      ],
    );
  }
}
