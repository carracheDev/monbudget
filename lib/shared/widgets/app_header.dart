import 'package:flutter/material.dart';
import 'package:monbudget/core/constants/app_colors.dart';

enum HeaderType {
  hamburger, // ≡ + titre + cloche
  back, // ← + titre
  action, // ← + titre + bouton action
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final HeaderType type;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onActionTap;
  final VoidCallback? onNotificationTap;
  final IconData? actionIcon;
  final int? notificationCount;

  const AppHeader({
    super.key,
    required this.title,
    required this.type,
    this.onMenuTap,
    this.onBackTap,
    this.onActionTap,
    this.onNotificationTap,
    this.actionIcon,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      leading: _buildLeading(context),
      actions: _buildActions(),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    switch (type) {
      case HeaderType.hamburger:
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
        );
      case HeaderType.back:
      case HeaderType.action:
        return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackTap ?? () => Navigator.pop(context),
        );
    }
  }

  List<Widget>? _buildActions() {
    switch (type) {
      case HeaderType.hamburger:
        return [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: onNotificationTap,
              ),
              // Badge rouge si notifications non lues
              if (notificationCount != null && notificationCount! > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ];
      case HeaderType.action:
        return [
          IconButton(
            icon: Icon(actionIcon ?? Icons.more_vert),
            onPressed: onActionTap,
          ),
        ];
      case HeaderType.back:
        return [];
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
