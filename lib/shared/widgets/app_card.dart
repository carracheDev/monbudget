import 'package:flutter/material.dart';
import 'package:monbudget/core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  // 🔥 NOUVEAUX PARAMÈTRES OPTIONNELS
  final Color? borderColor;
  final double borderWidth;
  final BorderSide? customBorderSide;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderWidth = 4,
    this.customBorderSide,
  });

  @override
  Widget build(BuildContext context) {
    // Couleur adaptative selon le thème
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.cardBackgroundDark
        : AppColors.cardBackgroundLight;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: color ?? cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: customBorderSide != null
              ? Border(left: customBorderSide!)
              : borderColor != null
              ? Border(
                  left: BorderSide(color: borderColor!, width: borderWidth),
                )
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
