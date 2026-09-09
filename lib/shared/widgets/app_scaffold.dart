import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool hasTopBlob;
  final bool hasBottomBlob;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.hasTopBlob = true,
    this.hasBottomBlob = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          if (hasTopBlob)
            Positioned(
              top: -50, left: -50,
              child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.blobCoral(0.3))),
            ),
          if (hasBottomBlob)
            Positioned(
              bottom: -50, right: -50,
              child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.blobAmber(0.2))),
            ),
          SafeArea(child: body),
        ],
      ),
    );
  }
}
