import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Clean, ambient AppScaffold providing consistent warm ivory background
/// and subtle ambient gradient depth layer for Warm Premium UI.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.useSafeArea = true,
    bool hasTopBlob = false,
    bool hasBottomBlob = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: body) : body;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Subtle ambient top-right warm glow for visual depth
          Positioned(
            top: -120,
            right: -80,
            width: 320,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}
