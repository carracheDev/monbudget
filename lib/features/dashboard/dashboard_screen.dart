import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/core/theme/app_text_styles.dart';
import 'package:monbudget/features/auth/auth_provider.dart';
import 'package:monbudget/features/comptes/compte_provider.dart';
import 'package:monbudget/features/transactions/add_transaction_sheet.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/widgets/app_card.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/filter_chip.dart';
import 'package:monbudget/shared/widgets/transaction_item.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _soldeVisible = true;
  String _periodeSelectionnee = 'Ce mois';
  final List<String> _periodes = ['Ce mois', '3 mois', 'Cette année'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
      ref.read(compteProvider.notifier).getCompte();
      ref.read(transactionsProvider.notifier).getTransactions();
    });
  }

  String dateFormatee() {
    return DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.now());
  }

  String _formatMontant(double montant) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(montant)} F';
  }

  // ================= BIENVENUE =================
  Widget _buildBienvenue() {
    final authState = ref.watch(authProvider);
    final nom = authState.user?.nomComplet.split(' ').first ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, $nom 👋',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          dateFormatee(),
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // ================= CARTE SOLDE =================
  Widget _buildCarteSolde() {
    final compteState = ref.watch(compteProvider);
    final solde = compteState.comptes.fold(0.0, (sum, c) => sum + c.solde);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Solde Actuel', style: AppTextStyles.labelSecondaire),
              IconButton(
                icon: Icon(
                  _soldeVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _soldeVisible = !_soldeVisible),
              ),
            ],
          ),
          compteState.isLoading
              ? const CircularProgressIndicator(color: AppColors.primary)
              : Text(
                  _soldeVisible ? _formatMontant(solde) : '••••• F',
                  style: AppTextStyles.montantPrincipal.copyWith(
                    color: AppColors.success,
                    fontSize: 32,
                  ),
                ),
          Text(
            "Mis à jour aujourd'hui",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= REVENUS / DÉPENSES =================
  Widget _buildRevenusDepenses() {
    final transactions = ref.watch(transactionsProvider).transactions;

    final revenus = transactions
        .where((t) => t.type.name == 'REVENU')
        .fold(0.0, (sum, t) => sum + t.montant);

    final depenses = transactions
        .where((t) => t.type.name == 'DEPENSE')
        .fold(0.0, (sum, t) => sum + t.montant);

    return Row(
      children: [
        Expanded(
          child: AppCard(
            borderColor: AppColors.success,
            borderWidth: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenus', style: AppTextStyles.labelSecondaire),
                Text(
                  '+${_formatMontant(revenus)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontSize: 16,
                  ),
                ),
                Text('Ce mois', style: AppTextStyles.labelSecondaire),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            customBorderSide: const BorderSide(
              color: AppColors.primary,
              width: 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dépenses', style: AppTextStyles.labelSecondaire),
                Text(
                  '-${_formatMontant(depenses)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                Text('Ce mois', style: AppTextStyles.labelSecondaire),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= GRAPHIQUE DONUT =================
  Widget _buildGraphiqueDonut() {
    final transactions = ref.watch(transactionsProvider).transactions;
    final depenses = transactions.where((t) => t.type.name == 'DEPENSE');

    // Grouper par categorieId
    final Map<String, double> parCategorie = {};
    for (final t in depenses) {
      parCategorie[t.categorieId] =
          (parCategorie[t.categorieId] ?? 0) + t.montant;
    }

    final total = parCategorie.values.fold(0.0, (a, b) => a + b);

    final couleurs = [
      AppColors.primary,
      AppColors.savings,
      AppColors.warning,
      AppColors.success,
      Colors.purple,
    ];

    final sections = parCategorie.entries.toList().asMap().entries.map((e) {
      final index = e.key;
      final entry = e.value;
      final pct = total > 0 ? (entry.value / total * 100) : 0.0;
      return PieChartSectionData(
        value: entry.value,
        color: couleurs[index % couleurs.length],
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + Filtres
          Text(
            'Répartition des dépenses',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Chips période
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periodes.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppFilterChip(
                    label: p,
                    isSelected: _periodeSelectionnee == p,
                    onTap: () => setState(() => _periodeSelectionnee = p),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Graphique
          sections.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aucune dépense ce mois',
                      style: AppTextStyles.labelSecondaire,
                    ),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),

          // Légende
          const SizedBox(height: 12),
          ...parCategorie.entries.toList().asMap().entries.map((e) {
            final index = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: couleurs[index % couleurs.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppTextStyles.labelSecondaire,
                    ),
                  ),
                  Text(
                    _formatMontant(entry.value),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= TRANSACTIONS RÉCENTES =================
  Widget _buildTransactionsRecentes() {
    final transState = ref.watch(transactionsProvider);
    final transactions = transState.transactions.take(3).toList();

    return Column(
      children: [
        // Titre + Voir tout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions Récentes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Voir tout',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Liste ou état vide
        transState.isLoading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : transactions.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('💸', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune transaction',
                        style: AppTextStyles.labelSecondaire,
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: transactions.map((t) {
                  return TransactionItem(
                    // ✅ Nom de la catégorie au lieu de UUID
                    title: t.description ?? t.categorie?.nom ?? 'Transaction',
                    date: DateFormat(
                      'dd/MM HH:mm',
                    ).format(DateTime.parse(t.date)),
                    amount: t.montant,
                    isIncome: t.type.name == 'REVENU',
                    // ✅ Icône selon le type
                    icon: t.type.name == 'REVENU'
                        ? Icons.arrow_downward
                        : t.type.name == 'TRANSFERT'
                        ? Icons.swap_horiz
                        : Icons.arrow_upward,
                  );
                }).toList(),
              ),
      ],
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'MonBudget',
        type: HeaderType.hamburger,
        onNotificationTap: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBienvenue(),
            const SizedBox(height: 16),
            _buildCarteSolde(),
            const SizedBox(height: 16),
            _buildRevenusDepenses(),
            const SizedBox(height: 16),
            _buildGraphiqueDonut(),
            const SizedBox(height: 16),
            _buildTransactionsRecentes(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
