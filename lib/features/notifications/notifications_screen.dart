import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/data/models/notification_model.dart';
import 'package:monbudget/features/notifications/notification_provider.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';
import 'package:monbudget/shared/widgets/filter_chip.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<String> _filtres = [
    'Toutes',
    'Non lues',
    'Alertes',
    'Transactions',
  ];
  String _filtreActif = 'Toutes';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationProvider.notifier).getNotifications();
    });
  }

  List<NotificationModel> _filtrer(List<NotificationModel> notifs) {
    switch (_filtreActif) {
      case 'Non lues':
        return notifs.where((n) => !n.estLu).toList();
      case 'Alertes':
        return notifs.where((n) => n.type == NotificationType.BUDGET).toList();
      case 'Transactions':
        return notifs
            .where((n) => n.type == NotificationType.TRANSACTION)
            .toList();
      default:
        return notifs;
    }
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.BUDGET:
        return AppColors.warning;
      case NotificationType.TRANSACTION:
        return AppColors.success;
      case NotificationType.OBJECTIF:
        return AppColors.savings;
      case NotificationType.SYSTEME:
        return AppColors.primary;
    }
  }

  String _getEmoji(NotificationType type) {
    switch (type) {
      case NotificationType.BUDGET:
        return '⚠️';
      case NotificationType.TRANSACTION:
        return '✅';
      case NotificationType.OBJECTIF:
        return '🎉';
      case NotificationType.SYSTEME:
        return '🔔';
    }
  }

  // ✅ FIX 1 — Détail notification
  void _showDetailNotif(NotificationModel notif) {
    final color = _getColor(notif.type);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getEmoji(notif.type),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notif.titre,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              notif.message,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(notif.dateCreation),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final filtrees = _filtrer(notifState.notifications);
    final nonLues = notifState.notifications.where((n) => !n.estLu).length;

    return Scaffold(
      appBar: AppHeader(
        title: 'Notifications',
        type: HeaderType.back,
        actionIcon: Icons.done_all,
        onActionTap: nonLues > 0
            ? () async {
                for (final n in notifState.notifications.where(
                  (n) => !n.estLu,
                )) {
                  await ref
                      .read(notificationProvider.notifier)
                      .marquerCommeLue(n.id);
                }
                if (mounted) {
                  AppToast.show(
                    context,
                    message: 'Toutes marquées comme lues ✓',
                    type: ToastType.success,
                  );
                }
              }
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filtres.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppFilterChip(
                      label: f,
                      isSelected: _filtreActif == f,
                      onTap: () => setState(() => _filtreActif = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: notifState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : filtrees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔔', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune notification',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtrees.length,
                    itemBuilder: (context, index) =>
                        _buildNotifItem(filtrees[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifItem(NotificationModel notif) {
    final color = _getColor(notif.type);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await ref
            .read(notificationProvider.notifier)
            .supprimerNotification(notif.id);
        if (mounted) {
          AppToast.show(
            context,
            message: 'Notification supprimée',
            type: ToastType.success,
          );
        }
      },
      child: InkWell(
        // ✅ FIX 1 — Ouvre le détail au tap
        onTap: () async {
          if (!notif.estLu) {
            await ref
                .read(notificationProvider.notifier)
                .marquerCommeLue(notif.id);
          }
          if (mounted) _showDetailNotif(notif);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.estLu ? Colors.white : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.estLu
                  ? Colors.grey.shade200
                  : color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEmoji(notif.type),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.titre,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: notif.estLu
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notif.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(notif.dateCreation),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.estLu)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
