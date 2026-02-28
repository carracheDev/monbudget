import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/features/auth/auth_provider.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/components/main_screen.dart';
import 'package:monbudget/shared/widgets/app_button.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/app_input.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
      ref.read(transactionsProvider.notifier).getTransactions();
    });
  }

  // ===== INITIALES AVATAR =====
  String _getInitiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.substring(0, 2).toUpperCase();
  }

  // ===== CARTE PROFIL =====
  Widget _buildCarteProfil() {
    final user = ref.watch(authProvider).user;
    final nom = user?.nomComplet ?? 'Utilisateur';
    final email = user?.email ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitiales(nom),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nom
          Text(
            nom,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),

          // Membre depuis
          Text(
            'Membre depuis ${DateFormat('MMM yyyy', 'fr_FR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ===== BLOC STATISTIQUES =====
  Widget _buildStatistiques() {
    final transactions = ref.watch(transactionsProvider).transactions;
    final totalDepense = transactions
        .where((t) => t.type.name == 'DEPENSE')
        .fold(0.0, (sum, t) => sum + t.montant);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transactions
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${transactions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Transactions',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Séparateur
          Container(width: 1, height: 60, color: Colors.grey.shade200),

          // Total dépensé
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${NumberFormat('#,###', 'fr_FR').format(totalDepense)} F',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Total dépensé',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PAGE MODIFIER PROFIL =====
  void _showModifierProfil() {
    final user = ref.read(authProvider).user;
    final nomController = TextEditingController(text: user?.nomComplet ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final telController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modifier le profil',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar avec bouton changer photo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitiales(user?.nomComplet ?? 'U'),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Champs
              AppInput(
                label: 'Nom complet',
                hintText: 'Jean Dupont',
                prefixIcon: Icons.person_outline,
                controller: nomController,
              ),
              const SizedBox(height: 16),

              AppInput(
                label: 'Email',
                hintText: 'exemple@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              const SizedBox(height: 16),

              AppInput(
                label: 'Téléphone',
                hintText: '+229 97 XX XX XX',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                controller: telController,
              ),
              const SizedBox(height: 24),

              // Bouton enregistrer
              AppButton(
                label: 'Enregistrer les modifications',
                onPressed: () async {
                  Navigator.pop(context);
                  AppToast.show(
                    context,
                    message: 'Profil mis à jour ✓',
                    type: ToastType.success,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Profil',
        type: HeaderType.hamburger,
        // Dans dashboard, transactions, etc.
        onNotificationTap: () => context.push('/notifications'),
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCarteProfil(),
            const SizedBox(height: 16),
            _buildStatistiques(),
            const SizedBox(height: 24),

            // Bouton modifier
            AppButton(
              label: 'Modifier le profil',
              onPressed: _showModifierProfil,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
