import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: AppColors.bgSecondary,
      alignment: Alignment.center,
      child: Text('Banner Ad Slot', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
    );
  }
}
