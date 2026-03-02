import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';

// Provider pour gérer les paramètres de notifications
final notificationsSettingsProvider =
    StateNotifierProvider<
      NotificationsSettingsNotifier,
      NotificationsSettingsState
    >((ref) {
      return NotificationsSettingsNotifier();
    });

class NotificationsSettingsState {
  final bool budgetAlerts;
  final bool transactionAlerts;
  final bool objectifAlerts;

  NotificationsSettingsState({
    this.budgetAlerts = true,
    this.transactionAlerts = true,
    this.objectifAlerts = true,
  });

  NotificationsSettingsState copyWith({
    bool? budgetAlerts,
    bool? transactionAlerts,
    bool? objectifAlerts,
  }) {
    return NotificationsSettingsState(
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      objectifAlerts: objectifAlerts ?? this.objectifAlerts,
    );
  }
}

class NotificationsSettingsNotifier
    extends StateNotifier<NotificationsSettingsState> {
  NotificationsSettingsNotifier() : super(NotificationsSettingsState());

  void toggleBudgetAlerts(bool value) {
    state = state.copyWith(budgetAlerts: value);
  }

  void toggleTransactionAlerts(bool value) {
    state = state.copyWith(transactionAlerts: value);
  }

  void toggleObjectifAlerts(bool value) {
    state = state.copyWith(objectifAlerts: value);
  }
}

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationsSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gérez les notifications que vous souhaitez recevoir',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications toggles
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Types de notifications',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Alertes budget
                _buildToggleItem(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Alertes budget',
                  subtitle:
                      'Notifications quand vous approchez ou dépassez votre budget',
                  value: settings.budgetAlerts,
                  onChanged: (value) {
                    ref
                        .read(notificationsSettingsProvider.notifier)
                        .toggleBudgetAlerts(value);
                  },
                ),
                const Divider(height: 1),

                // Transactions
                _buildToggleItem(
                  context: context,
                  icon: Icons.swap_horiz,
                  title: 'Transactions',
                  subtitle: 'Notifications pour chaque transaction effectuée',
                  value: settings.transactionAlerts,
                  onChanged: (value) {
                    ref
                        .read(notificationsSettingsProvider.notifier)
                        .toggleTransactionAlerts(value);
                  },
                ),
                const Divider(height: 1),

                // Objectifs
                _buildToggleItem(
                  context: context,
                  icon: Icons.flag_outlined,
                  title: 'Objectifs',
                  subtitle: 'Notifications sur vos objectifs d\'épargne',
                  value: settings.objectifAlerts,
                  onChanged: (value) {
                    ref
                        .read(notificationsSettingsProvider.notifier)
                        .toggleObjectifAlerts(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Information',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous pouvez désactiver complètement les notifications depuis les paramètres de votre appareil.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
