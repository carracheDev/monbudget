import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/features/notifications/notification_provider.dart';

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
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onMenuTap,
        );
      case HeaderType.back:
      case HeaderType.action:
        return IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBackTap ?? () => Navigator.pop(context),
        );
    }
  }

  List<Widget>? _buildActions() {
    switch (type) {
      case HeaderType.hamburger:
        return [
          Consumer(
            builder: (context, ref, _) {
              final nonLues = ref
                  .watch(notificationProvider)
                  .notifications
                  .where((n) => !n.estLu)
                  .length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: onNotificationTap,
                  ),
                  if (nonLues > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            nonLues > 9 ? '9+' : '$nonLues',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ];
      case HeaderType.action:
        return [
          IconButton(
            icon: Icon(actionIcon ?? Icons.more_vert, color: Colors.white),
            onPressed: onActionTap,
          ),
        ];
      case HeaderType.back:
        // ✅ Afficher actionIcon si fourni
        if (actionIcon != null) {
          return [
            IconButton(
              icon: Icon(actionIcon!, color: Colors.white),
              onPressed: onActionTap,
            ),
          ];
        }
        return [];
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
