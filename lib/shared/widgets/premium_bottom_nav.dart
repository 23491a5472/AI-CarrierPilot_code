import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;

  const PremiumBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/analyze'); break;
      case 2: context.go('/jobs'); break;
      case 3: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5))),
            boxShadow: AppShadows.glass,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: LucideIcons.home, label: 'Home', isSelected: currentIndex == 0, onTap: () => _onTap(context, 0)),
                  _NavItem(icon: LucideIcons.scanLine, label: 'Analyze', isSelected: currentIndex == 1, onTap: () => _onTap(context, 1)),
                  _NavItem(icon: LucideIcons.briefcase, label: 'Jobs', isSelected: currentIndex == 2, onTap: () => _onTap(context, 2)),
                  _NavItem(icon: LucideIcons.user, label: 'Profile', isSelected: currentIndex == 3, onTap: () => _onTap(context, 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: isSelected ? AppColors.secondary : AppColors.textLight, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.secondary : AppColors.textLight,
            ),
          )
        ],
      ),
    );
  }
}
