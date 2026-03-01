import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/data/models/budget_model.dart';
import 'package:monbudget/features/budgets/budget_provider.dart';
import 'package:monbudget/features/categories/categorie_provider.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/widgets/app_button.dart';
import 'package:monbudget/shared/widgets/app_card.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';
import 'package:monbudget/shared/widgets/progress_bar.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(budgetsProvider.notifier).getBudgets();
      ref.read(transactionsProvider.notifier).getTransactions();
      ref.read(categorieProvider.notifier).getCategories();
    });
  }

  String _formatMontant(double montant) {
    return '${NumberFormat('#,###', 'fr_FR').format(montant)} F';
  }

  String _getPeriodeLabel(BudgetPeriode periode) {
    switch (periode) {
      case BudgetPeriode.MENSUEL:
        return 'Mensuel';
      case BudgetPeriode.HEBDOMADAIRE:
        return 'Hebdomadaire';
      case BudgetPeriode.TRIMESTRIEL:
        return 'Trimestriel';
      case BudgetPeriode.ANNUEL:
        return 'Annuel';
    }
  }

  Color _getCouleurBudget(double pct) {
    if (pct >= 85) return AppColors.primary;
    if (pct >= 60) return AppColors.warning;
    return AppColors.success;
  }

  // Calculer montant dépensé pour une catégorie
  double _getMontantDepense(String categorieId) {
    final transactions = ref.read(transactionsProvider).transactions;
    return transactions
        .where((t) => t.categorieId == categorieId && t.type.name == 'DEPENSE')
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  // ===== LÉGENDE COULEURS =====
  Widget _buildLegende() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendeItem('🟢', 'Contrôle', '< 60%'),
          _legendeItem('🟠', 'Attention', '60-85%'),
          _legendeItem('🔴', 'Limite', '> 85%'),
        ],
      ),
    );
  }

  Widget _legendeItem(String emoji, String label, String pct) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
        Text(
          pct,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ===== CARTE BUDGET =====
  Widget _buildCarteBudget(BudgetModel budget) {
    // ✅ ref.watch → se met à jour automatiquement
    final transactions = ref.watch(transactionsProvider).transactions;

    final depense = transactions
        .where(
          (t) =>
              t.categorieId == budget.categorieId && t.type.name == 'DEPENSE',
        )
        .fold(0.0, (sum, t) => sum + t.montant);

    final pct = budget.montantLimite > 0
        ? (depense / budget.montantLimite * 100).clamp(0, 100)
        : 0.0;
    final couleur = _getCouleurBudget(pct.toDouble());

    return AppCard(
      onTap: () => _showDetailBudget(budget, depense, pct.toDouble()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                budget.categorie?.icone ?? '📦',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.categorie?.nom ?? 'Budget',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_formatMontant(depense)} / ${_formatMontant(budget.montantLimite)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (pct >= 85)
                    const Text('⚠️', style: TextStyle(fontSize: 16)),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: couleur,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(
            value: pct / 100,
            color: couleur,
            height: 8,
            showPercentage: false,
          ),
        ],
      ),
    );
  }

  // ===== DÉTAIL BUDGET =====
  void _showDetailBudget(BudgetModel budget, double depense, double pct) {
    final transactions = ref
        .read(transactionsProvider)
        .transactions
        .where((t) => t.categorieId == budget.categorieId)
        .toList();
    final couleur = _getCouleurBudget(pct);
    final restant = budget.montantLimite - depense;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              // Icône + nom
              Center(
                child: Column(
                  children: [
                    Text(
                      budget.categorie?.icone ?? '📦',
                      style: const TextStyle(fontSize: 48),
                    ),
                    Text(
                      budget.categorie?.nom ?? 'Budget',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Donut chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: depense,
                        color: couleur,
                        title: 'Dépensé',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: restant > 0 ? restant : 0,
                        color: Colors.grey.shade200,
                        title: 'Restant',
                        titleStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        radius: 60,
                      ),
                    ],
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Résumé
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resumeItem('Dépensé', _formatMontant(depense), couleur),
                  _resumeItem(
                    'Restant',
                    _formatMontant(restant > 0 ? restant : 0),
                    AppColors.success,
                  ),
                  _resumeItem(
                    'Plafond',
                    _formatMontant(budget.montantLimite),
                    Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Historique transactions
              Text(
                'Transactions liées',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...transactions
                  .take(5)
                  .map(
                    (t) => ListTile(
                      leading: Text(
                        t.categorie?.icone ?? '💸',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        t.description ?? t.categorie?.nom ?? '-',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(t.date),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        '-${_formatMontant(t.montant)}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Modifier',
                      isOutlined: true,
                      onPressed: () {
                        Navigator.pop(context);
                        _showModifierBudget(budget);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Supprimer',
                      onPressed: () => _confirmerSuppression(budget),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumeItem(String label, String valeur, Color color) {
    return Column(
      children: [
        Text(
          valeur,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // ===== MODIFIER BUDGET =====
  void _showModifierBudget(BudgetModel budget) {
    final controller = TextEditingController(
      text: budget.montantLimite.toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Modifier le plafond',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nouveau plafond (F CFA)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
              // TODO: implémenter updateBudget dans le provider
            },
            child: Text(
              'Enregistrer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SUPPRESSION =====
  void _confirmerSuppression(BudgetModel budget) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Supprimer ?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Cette action est irréversible.',
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
              await ref.read(budgetsProvider.notifier).deleteBudget(budget.id);
              if (mounted) {
                AppToast.show(
                  context,
                  message: 'Budget supprimé',
                  type: ToastType.success,
                );
              }
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ===== MODALE AJOUTER BUDGET =====
  void _showAjouterBudget() {
    final montantController = TextEditingController();
    String? categorieId;
    BudgetPeriode periode = BudgetPeriode.MENSUEL;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final categories = ref.watch(categorieProvider).categories;
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nouveau Budget',
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

                  // Catégorie + bouton créer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Catégorie',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // ✅ Bouton créer catégorie
                      TextButton.icon(
                        onPressed: () => _showCreerCategorie(setModalState),
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        label: Text(
                          'Nouvelle',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = categorieId == cat.id;
                      return GestureDetector(
                        onTap: () => setModalState(() => categorieId = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cat.icone} ${cat.nom}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Montant
                  Text(
                    'Plafond (F CFA)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montantController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 50 000',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Période
                  Text(
                    'Période',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BudgetPeriode.values.map((p) {
                      final isSelected = periode == p;
                      return GestureDetector(
                        onTap: () => setModalState(() => periode = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPeriodeLabel(p),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Bouton créer
                  AppButton(
                    label: 'Créer le budget',
                    onPressed:
                        categorieId != null && montantController.text.isNotEmpty
                        ? () async {
                            final budgetState = ref.read(budgetsProvider);

                            // ✅ Vérifier doublon côté Flutter
                            final doublon = budgetState.budgets.any(
                              (b) =>
                                  b.categorieId == categorieId &&
                                  b.periode == periode,
                            );

                            if (doublon) {
                              AppToast.show(
                                context,
                                message:
                                    'Un budget existe déjà pour cette catégorie et période !',
                                type: ToastType.error,
                              );
                              return;
                            }

                            await ref
                                .read(budgetsProvider.notifier)
                                .createBudget(
                                  categorieId: categorieId!,
                                  montantLimite: double.parse(
                                    montantController.text,
                                  ),
                                  periode: periode,
                                );

                            final state = ref.read(budgetsProvider);
                            if (state.error != null) {
                              if (mounted) {
                                AppToast.show(
                                  context,
                                  message: state.error!,
                                  type: ToastType.error,
                                );
                              }
                            } else {
                              if (mounted) {
                                Navigator.pop(context);
                                AppToast.show(
                                  context,
                                  message: 'Budget créé ✓',
                                  type: ToastType.success,
                                );
                              }
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Créer catégorie personnalisée
  void _showCreerCategorie(StateSetter setModalState) {
    final nomController = TextEditingController();
    final iconeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Nouvelle catégorie',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: iconeController,
              decoration: InputDecoration(
                labelText: 'Icône (emoji)',
                hintText: '🛒',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex: Loyer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
              if (nomController.text.isNotEmpty) {
                await ref
                    .read(categorieProvider.notifier)
                    .createCategorie(
                      nom: nomController.text,
                      icone: iconeController.text.isEmpty
                          ? '📦'
                          : iconeController.text,
                    );
                if (mounted) {
                  Navigator.pop(context);
                  // ✅ Rafraîchir la liste des catégories dans la modale
                  setModalState(() {});
                }
              }
            },
            child: Text(
              'Créer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppHeader(
        title: 'Budgets',
        type: HeaderType.hamburger,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        // Dans dashboard, transactions, etc.
        onNotificationTap: () => context.push('/notifications'),
      ),
      body: budgetState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : budgetState.budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun budget configuré',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: '+ Créer un budget',
                    onPressed: _showAjouterBudget,
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLegende(),
                const SizedBox(height: 16),
                ...budgetState.budgets.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCarteBudget(b),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budget',
        onPressed: _showAjouterBudget,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
