import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/core/config/providers.dart';
import 'package:monbudget/data/models/transaction_model.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/widgets/app_drawer.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';

class RapportsScreen extends ConsumerStatefulWidget {
  const RapportsScreen({super.key});

  @override
  ConsumerState<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends ConsumerState<RapportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _periode = 'Mensuel';
  DateTime _moisSelectionne = DateTime.now();
  String _toggleGraphique = 'Les deux';
  bool _loadingPdf = false;
  bool _loadingExcel = false;

  final List<String> _periodes = ['Mensuel', 'Trimestriel', 'Annuel'];
  final List<String> _toggleOptions = ['Dépenses', 'Revenus', 'Les deux'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionsProvider.notifier).getTransactions();
    });
  }

  // ===== DONNÉES CALCULÉES =====
  List<TransactionModel> _getTransactionsFiltrees() {
    final transactions = ref.watch(transactionsProvider).transactions;
    return transactions.where((t) {
      final date = DateTime.parse(t.dateCreation);
      if (_periode == 'Mensuel') {
        return date.year == _moisSelectionne.year &&
            date.month == _moisSelectionne.month;
      } else if (_periode == 'Trimestriel') {
        final trimestre = ((_moisSelectionne.month - 1) ~/ 3);
        final moisTrimestre = (date.month - 1) ~/ 3;
        return date.year == _moisSelectionne.year && moisTrimestre == trimestre;
      } else {
        return date.year == _moisSelectionne.year;
      }
    }).toList();
  }

  double _getTotalRevenus(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.REVENU)
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  double _getTotalDepenses(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.DEPENSE)
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  // ===== SÉLECTEUR PÉRIODE =====
  Widget _buildSelectorPeriode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _periodes.map((p) {
              final selected = _periode == p;
              return GestureDetector(
                onTap: () => setState(() => _periode = p),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(_moisSelectionne),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _moisSelectionne,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _moisSelectionne = date);
  }

  // ===== BLOC RÉSUMÉ =====
  Widget _buildResume(double revenus, double depenses) {
    final solde = revenus - depenses;
    return Container(
      padding: const EdgeInsets.all(16),
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
          _buildMetrique(
            'Revenus',
            revenus,
            AppColors.success,
            Icons.arrow_upward,
          ),
          _buildDivider(),
          _buildMetrique(
            'Dépenses',
            depenses,
            AppColors.primary,
            Icons.arrow_downward,
          ),
          _buildDivider(),
          _buildMetrique(
            'Solde',
            solde,
            Colors.blue,
            Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMetrique(
    String label,
    double montant,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '${NumberFormat('#,###', 'fr_FR').format(montant)} F',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  // ===== GRAPHIQUE TENDANCE =====
  Widget _buildGraphiqueTendance() {
    final allTransactions = ref.watch(transactionsProvider).transactions;

    final mois = List.generate(6, (i) {
      final m = DateTime.now();
      return DateTime(m.year, m.month - (5 - i));
    });

    double maxVal = 1.0;
    for (final m in mois) {
      final txMois = allTransactions.where(
        (t) =>
            DateTime.parse(t.dateCreation).year == m.year &&
            DateTime.parse(t.dateCreation).month == m.month,
      );
      final depenses = txMois
          .where((t) => t.type == TransactionType.DEPENSE)
          .fold(0.0, (s, t) => s + t.montant);
      final revenus = txMois
          .where((t) => t.type == TransactionType.REVENU)
          .fold(0.0, (s, t) => s + t.montant);
      if (depenses > maxVal) maxVal = depenses;
      if (revenus > maxVal) maxVal = revenus;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendance des 6 mois',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _toggleOptions.map((opt) {
                final selected = _toggleGraphique == opt;
                return GestureDetector(
                  onTap: () => setState(() => _toggleGraphique = opt),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      opt,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: selected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const barreHauteurMax = 120.0;
              return SizedBox(
                height: barreHauteurMax + 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: mois.map((m) {
                    final txMois = allTransactions.where(
                      (t) =>
                          DateTime.parse(t.dateCreation).year == m.year &&
                          DateTime.parse(t.dateCreation).month == m.month,
                    );

                    final depenses = txMois
                        .where((t) => t.type == TransactionType.DEPENSE)
                        .fold(0.0, (s, t) => s + t.montant);
                    final revenus = txMois
                        .where((t) => t.type == TransactionType.REVENU)
                        .fold(0.0, (s, t) => s + t.montant);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_toggleGraphique != 'Dépenses')
                          _buildBarre(
                            revenus,
                            maxVal,
                            barreHauteurMax,
                            AppColors.success,
                          ),
                        if (_toggleGraphique == 'Les deux')
                          const SizedBox(height: 2),
                        if (_toggleGraphique != 'Revenus')
                          _buildBarre(
                            depenses,
                            maxVal,
                            barreHauteurMax,
                            AppColors.primary,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM', 'fr_FR').format(m),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarre(
    double valeur,
    double max,
    double hauteurMax,
    Color color,
  ) {
    final hauteur = max == 0
        ? 4.0
        : (valeur / max * hauteurMax).clamp(4.0, hauteurMax);
    return Container(
      width: 16,
      height: hauteur,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ===== DÉTAIL PAR CATÉGORIE =====
  Widget _buildDetailCategories(List<TransactionModel> transactions) {
    final depenses = transactions
        .where((t) => t.type == TransactionType.DEPENSE)
        .toList();

    final Map<String, double> parCategorie = {};
    for (final t in depenses) {
      final nom = t.categorie?.nom ?? 'Autre';
      parCategorie[nom] = (parCategorie[nom] ?? 0) + t.montant;
    }

    final total = parCategorie.values.fold(0.0, (s, v) => s + v);
    final sorted = parCategorie.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dépenses par catégorie',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            Center(
              child: Text(
                'Aucune dépense sur cette période',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          else
            ...sorted.map((entry) {
              final pct = total == 0 ? 0.0 : (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${NumberFormat('#,###', 'fr_FR').format(entry.value)} F',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
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

  // ===== BOUTONS EXPORT =====
  Future<void> _exporterPdf() async {
    setState(() => _loadingPdf = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.dio.get(
        '/rapports/exporter',
        queryParameters: {
          'format': 'pdf',
          'periode': _periode.toLowerCase(),
          'mois': _moisSelectionne.month,
          'annee': _moisSelectionne.year,
        },
      );
      if (mounted) {
        AppToast.show(
          context,
          message: 'Rapport PDF téléchargé ✓',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Erreur export PDF',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingPdf = false);
    }
  }

  Future<void> _exporterExcel() async {
    setState(() => _loadingExcel = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.dio.get(
        '/rapports/exporter',
        queryParameters: {
          'format': 'excel',
          'periode': _periode.toLowerCase(),
          'mois': _moisSelectionne.month,
          'annee': _moisSelectionne.year,
        },
      );
      if (mounted) {
        AppToast.show(
          context,
          message: 'Rapport Excel exporté ✓',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Erreur export Excel',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingExcel = false);
    }
  }

  Widget _buildBoutonsExport() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _loadingPdf ? null : _exporterPdf,
            icon: _loadingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('📄', style: TextStyle(fontSize: 18)),
            label: Text(
              _loadingPdf ? 'Génération...' : 'Télécharger en PDF',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _loadingExcel ? null : _exporterExcel,
            icon: _loadingExcel
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('📊', style: TextStyle(fontSize: 18)),
            label: Text(
              _loadingExcel ? 'Génération...' : 'Exporter en Excel',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);
    final filtrees = _getTransactionsFiltrees();
    final revenus = _getTotalRevenus(filtrees);
    final depenses = _getTotalDepenses(filtrees);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppHeader(
        title: 'Rapports',
        type: HeaderType.hamburger,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onNotificationTap: () => context.push('/notifications'),
      ),
      backgroundColor: Colors.grey.shade50,
      body: transactionsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectorPeriode(),
                  const SizedBox(height: 16),
                  _buildResume(revenus, depenses),
                  const SizedBox(height: 16),
                  _buildGraphiqueTendance(),
                  const SizedBox(height: 16),
                  _buildDetailCategories(filtrees),
                  const SizedBox(height: 16),
                  _buildBoutonsExport(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
