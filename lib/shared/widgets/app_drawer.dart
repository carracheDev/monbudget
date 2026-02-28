import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/features/auth/auth_provider.dart';
import 'package:monbudget/shared/components/main_screen.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).checkAuth());
  }

  String _getInitiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.substring(0, 2).toUpperCase();
  }

  void _naviguer(int index) {
    Navigator.pop(context); // Fermer le drawer
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }

  void _confirmerDeconnexion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/login');
            },
            child: Text(
              'Confirmer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.primary : Colors.grey),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppColors.primary : Colors.black87,
        ),
      ),
      tileColor: isActive
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final nom = user?.nomComplet ?? 'Utilisateur';
    final email = user?.email ?? '';
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ===== EN-TÊTE ROUGE =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                children: [
                  // Bouton fermer + Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MonBudget',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Avatar + infos
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitiales(nom),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nom,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===== NAVIGATION =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    _buildItem(
                      icon: Icons.home_outlined,
                      label: 'Accueil',
                      isActive: currentIndex == 0,
                      onTap: () => _naviguer(0),
                    ),
                    _buildItem(
                      icon: Icons.swap_horiz,
                      label: 'Transactions',
                      isActive: currentIndex == 1,
                      onTap: () => _naviguer(1),
                    ),
                    _buildItem(
                      icon: Icons.bar_chart,
                      label: 'Statistiques',
                      isActive: currentIndex == 2,
                      onTap: () => _naviguer(2),
                    ),
                    _buildItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Budgets',
                      isActive: currentIndex == 3,
                      onTap: () => _naviguer(3),
                    ),
                    _buildItem(
                      icon: Icons.savings_outlined,
                      label: 'Épargne',
                      isActive: false,
                      onTap: ()=> context.push('/epargne'),
                    ),
                    _buildItem(
                      icon: Icons.wallet_outlined,
                      label: 'Portefeuille',
                      isActive: false,
                      onTap: () => context.push('/portefeuille'),
                    ),
                    _buildItem(
                      icon: Icons.description_outlined,
                      label: 'Rapports',
                      isActive: false,
                      onTap: () {},
                    ),
                    _buildItem(
                      icon: Icons.settings_outlined,
                      label: 'Paramètres',
                      isActive: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ===== DÉCONNEXION =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.primary),
                title: Text(
                  'Se déconnecter',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primary),
                ),
                onTap: _confirmerDeconnexion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
