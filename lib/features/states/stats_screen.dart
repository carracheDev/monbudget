import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/core/theme/app_text_styles.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/widgets/app_card.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/filter_chip.dart';
import 'package:monbudget/shared/widgets/progress_bar.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final List<String> _filtres = ['7j', '30j', '3 mois', 'Année'];
  String _filtreActif = '7j';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionsProvider.notifier).getTransactions();
    });
  }

  String _formatMontant(double montant) {
    return '${NumberFormat('#,###', 'fr_FR').format(montant)} F';
  }

  // ===== MÉTRIQUES =====
  Widget _buildMetriques() {
    final transactions = ref.watch(transactionsProvider).transactions;

    final revenus = transactions
        .where((t) => t.type.name == 'REVENU')
        .fold(0.0, (sum, t) => sum + t.montant);

    final depenses = transactions
        .where((t) => t.type.name == 'DEPENSE')
        .fold(0.0, (sum, t) => sum + t.montant);

    final economies = revenus - depenses;

    return Row(
      children: [
        _metriqueCard('Revenus', revenus, AppColors.success),
        const SizedBox(width: 8),
        _metriqueCard('Dépenses', depenses, AppColors.primary),
        const SizedBox(width: 8),
        _metriqueCard('Économies', economies, AppColors.savings),
      ],
    );
  }

  Widget _metriqueCard(String label, double montant, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSecondaire),
            const SizedBox(height: 4),
            Text(
              _formatMontant(montant),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== GRAPHIQUE À BARRES =====
  // 💡 EXPLICATION DU GRAPHIQUE :
  // BarChart de fl_chart utilise :
  //   - BarChartGroupData : un groupe de barres pour un jour/mois
  //   - BarChartRodData   : une barre individuelle (rouge ou verte)
  //   - x                 : position sur l'axe horizontal (0, 1, 2...)
  //   - toY               : hauteur de la barre (= montant)
  Widget _buildGraphique() {
    final transactions = ref.watch(transactionsProvider).transactions;

    // Grouper les transactions par jour (7 derniers jours)
    final Map<int, double> revenusParJour = {};
    final Map<int, double> depensesParJour = {};

    for (final t in transactions) {
      final date = DateTime.parse(t.date);
      final diff = DateTime.now().difference(date).inDays;
      if (diff > 6) continue; // Garder seulement 7 jours
      final jour = 6 - diff; // 0 = il y a 6 jours, 6 = aujourd'hui

      if (t.type.name == 'REVENU') {
        revenusParJour[jour] = (revenusParJour[jour] ?? 0) + t.montant;
      } else if (t.type.name == 'DEPENSE') {
        depensesParJour[jour] = (depensesParJour[jour] ?? 0) + t.montant;
      }
    }

    // Créer les barres pour chaque jour
    final barGroups = List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          // Barre verte = revenus
          BarChartRodData(
            toY: revenusParJour[i] ?? 0,
            color: AppColors.success,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          // Barre rouge = dépenses
          BarChartRodData(
            toY: depensesParJour[i] ?? 0,
            color: AppColors.primary,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendance',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Légende
          Row(
            children: [
              _legendeItem('Revenus', AppColors.success),
              const SizedBox(width: 16),
              _legendeItem('Dépenses', AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  // Axe du bas = jours
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - value.toInt()),
                        );
                        return Text(
                          DateFormat('dd/MM').format(date),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Cacher les autres axes
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendeItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSecondaire),
      ],
    );
  }

  // ===== TOP CATÉGORIES =====
  Widget _buildTopCategories() {
    final transactions = ref.watch(transactionsProvider).transactions;

    // Grouper dépenses par catégorie
    final Map<String, Map<String, dynamic>> parCategorie = {};
    for (final t in transactions.where((t) => t.type.name == 'DEPENSE')) {
      final nom = t.categorie?.nom ?? 'Autre';
      final icone = t.categorie?.icone ?? '📦';
      parCategorie[nom] ??= {'montant': 0.0, 'icone': icone};
      parCategorie[nom]!['montant'] += t.montant;
    }

    final total = parCategorie.values.fold(
      0.0,
      (sum, v) => sum + (v['montant'] as double),
    );

    // Trier par montant décroissant
    final sorted = parCategorie.entries.toList()
      ..sort(
        (a, b) => (b.value['montant'] as double).compareTo(
          a.value['montant'] as double,
        ),
      );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Catégories',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            Center(
              child: Text(
                'Aucune dépense',
                style: AppTextStyles.labelSecondaire,
              ),
            )
          else
            ...sorted.take(5).map((entry) {
              final montant = entry.value['montant'] as double;
              final icone = entry.value['icone'] as String;
              final pct = total > 0 ? montant / total : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(icone, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatMontant(montant),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppProgressBar(
                      value: pct,
                      color: AppColors.primary,
                      height: 6,
                      showPercentage: false,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Statistiques',
        type: HeaderType.hamburger,
        // Dans dashboard, transactions, etc.
        onNotificationTap: () => context.push('/notifications'),
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chips période
            SingleChildScrollView(
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
            const SizedBox(height: 16),
            _buildMetriques(),
            const SizedBox(height: 16),
            _buildGraphique(),
            const SizedBox(height: 16),
            _buildTopCategories(),
            const SizedBox(height: 16),

            // Bouton rapport complet
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Voir le rapport complet',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
