import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/features/portefeuille/portefeuille_provider.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/components/main_screen.dart';
import 'package:monbudget/shared/widgets/app_button.dart';
import 'package:monbudget/shared/widgets/app_drawer.dart';
import 'package:monbudget/shared/widgets/app_header.dart';

class PortefeuilleScreen extends ConsumerStatefulWidget {
  const PortefeuilleScreen({super.key});

  @override
  ConsumerState<PortefeuilleScreen> createState() => _PortefeuilleScreenState();
}

class _PortefeuilleScreenState extends ConsumerState<PortefeuilleScreen> {
  // ✅ GlobalKey pour le drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(portefeuilleProvider.notifier).getPortefeuille();
      ref.read(transactionsProvider.notifier).getTransactions();
    });
  }

  // ===== CARTE SOLDE =====
  Widget _buildCarteSolde(double solde) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Solde Disponible',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,###', 'fr_FR').format(solde)} F',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prêt à être utilisé',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ===== GRILLE ACTIONS 2x2 =====
  Widget _buildGrilleActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionItem(
          icon: Icons.add_circle_outline,
          label: 'Recharger',
          onTap: () => _showModaleRecharger(),
          disponible: true,
        ),
        _buildActionItem(
          icon: Icons.payment_outlined,
          label: 'Payer',
          onTap: () => _showModalePayer(),
          disponible: true,
        ),
        _buildActionItem(
          icon: Icons.send_outlined,
          label: 'Transférer',
          onTap: null,
          disponible: false,
        ),
        _buildActionItem(
          icon: Icons.arrow_upward_outlined,
          label: 'Retirer',
          onTap: null,
          disponible: false,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool disponible,
  }) {
    return GestureDetector(
      onTap: disponible ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: disponible
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: disponible ? AppColors.primary : Colors.grey.shade400,
                  size: 32,
                ),
                if (!disponible)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.lock,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: disponible ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== TRANSACTIONS RÉCENTES =====
  Widget _buildTransactionsRecentes() {
    final transactions = ref.watch(transactionsProvider).transactions;
    final recentes = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions Récentes',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (recentes.isEmpty)
          Center(
            child: Text(
              'Aucune transaction',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          )
        else
          ...recentes.map((t) {
            final isRevenu = t.type.name == 'REVENU';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isRevenu
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        t.categorie?.icone ?? '💳',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.categorie?.nom ?? 'Transaction',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(t.date),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isRevenu ? '+' : '-'}${NumberFormat('#,###', 'fr_FR').format(t.montant)} F',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isRevenu ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 12),
        AppButton(
          label: 'Voir l\'historique complet',
          onPressed: () {
            context.pop();
            ref.read(bottomNavIndexProvider.notifier).state = 1;
            context.pop();
          },
        ),
      ],
    );
  }

  // ===== MODALE RECHARGER =====
  void _showModaleRecharger() {
    _showModaleOperation(titre: 'Recharger le Portefeuille', isPaiement: false);
  }

  void _showModalePayer() {
    _showModaleOperation(titre: 'Paiement Marchand', isPaiement: true);
  }

  void _showModaleOperation({required String titre, required bool isPaiement}) {
    String? operateurSelectionne;
    final montantController = TextEditingController();
    final numeroController = TextEditingController();
    final operateurs = [
      'MTN Mobile Money',
      'Moov Money',
      'Wave',
      'Celtis',
      'Autres',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titre,
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
                Text(
                  'Opérateur Mobile Money',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: operateurs.map((op) {
                    final selected = operateurSelectionne == op;
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => operateurSelectionne = op),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          op,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: selected ? Colors.white : Colors.grey,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Montant (F CFA)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final val = int.tryParse(montantController.text) ?? 0;
                        if (val >= 500) {
                          setModalState(
                            () => montantController.text = '${val - 500}',
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: montantController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final val = int.tryParse(montantController.text) ?? 0;
                        setModalState(
                          () => montantController.text = '${val + 500}',
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  operateurSelectionne != null
                      ? 'Numéro ${operateurSelectionne!.split(' ').first}'
                      : 'Numéro',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: numeroController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: '+229 97 XX XX XX',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Une notification de confirmation vous sera envoyée après la transaction.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          operateurSelectionne != null &&
                              montantController.text.isNotEmpty &&
                              numeroController.text.isNotEmpty
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed:
                        operateurSelectionne != null &&
                            montantController.text.isNotEmpty &&
                            numeroController.text.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            _showConfirmation(
                              montant: montantController.text,
                              operateur: operateurSelectionne!,
                              numero: numeroController.text,
                              isPaiement: isPaiement,
                            );
                          }
                        : null,
                    child: Text(
                      isPaiement
                          ? 'Confirmer le Paiement'
                          : 'Confirmer la Recharge',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== PAGE CONFIRMATION =====
  void _showConfirmation({
    required String montant,
    required String operateur,
    required String numero,
    required bool isPaiement,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirmation',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Vous allez ${isPaiement ? 'payer' : 'recharger'} $montant F via $operateur au $numero',
                style: GoogleFonts.poppins(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.poppins(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (!isPaiement) {
                        ref
                            .read(portefeuilleProvider.notifier)
                            .recharger(
                              montant: double.parse(montant),
                              operateur: operateur,
                              numeroTelephone: numero,
                            );
                      }
                      _showSucces(
                        montant: montant,
                        operateur: operateur,
                        isPaiement: isPaiement,
                      );
                    },
                    child: Text(
                      'Confirmer définitivement',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== MODALE SUCCÈS =====
  void _showSucces({
    required String montant,
    required String operateur,
    required bool isPaiement,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPaiement ? 'Paiement Réussi !' : 'Recharge Réussie !',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$montant F via $operateur',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
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
                  'Terminer',
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
    final portefeuilleState = ref.watch(portefeuilleProvider);
    final solde = portefeuilleState.portefeuille?.solde ?? 0.0;

    return Scaffold(
      key: _scaffoldKey, // ✅ GlobalKey
      drawer: const AppDrawer(), // ✅ Drawer
      appBar: AppHeader(
        title: 'Mon Portefeuille',
        type: HeaderType.hamburger,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(), // ✅
        onNotificationTap: () => context.push('/notifications'),
      ),
      backgroundColor: Colors.grey.shade50,
      body: portefeuilleState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCarteSolde(solde),
                  const SizedBox(height: 16),
                  _buildGrilleActions(),
                  const SizedBox(height: 24),
                  _buildTransactionsRecentes(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
