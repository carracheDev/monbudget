import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/data/models/transaction_model.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/filter_chip.dart';
import 'package:monbudget/shared/widgets/transaction_item.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filtreActif = 'Tout';
  String _recherche = '';
  final List<String> _filtres = ['Tout', 'Revenus', 'Dépenses', 'Transferts'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionsProvider.notifier).getTransactions();
    });
  }

  String _formatMontant(double montant) {
    return NumberFormat('#,###', 'fr_FR').format(montant);
  }

  List<TransactionModel> _filtrerTransactions(
      List<TransactionModel> transactions) {
    return transactions.where((t) {
      // Filtre type
      if (_filtreActif == 'Revenus' && t.type.name != 'REVENU') return false;
      if (_filtreActif == 'Dépenses' && t.type.name != 'DEPENSE') return false;
      if (_filtreActif == 'Transferts' && t.type.name != 'TRANSFERT')
        return false;

      // Filtre recherche
      if (_recherche.isNotEmpty) {
        final nom =
            (t.description ?? t.categorie?.nom ?? '').toLowerCase();
        if (!nom.contains(_recherche.toLowerCase())) return false;
      }

      return true;
    }).toList();
  }

  // Grouper par date
  Map<String, List<TransactionModel>> _grouperParDate(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> groupes = {};
    for (final t in transactions) {
      final date = DateFormat('dd MMMM yyyy', 'fr_FR')
          .format(DateTime.parse(t.date));
      groupes.putIfAbsent(date, () => []).add(t);
    }
    return groupes;
  }

  void _showDetail(TransactionModel t) {
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
            // Icône catégorie
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: t.type.name == 'REVENU'
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  t.categorie?.icone ?? '💸',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Montant
            Text(
              '${t.type.name == 'REVENU' ? '+' : '-'}${_formatMontant(t.montant)} F',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: t.type.name == 'REVENU'
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Détails
            _detailRow('Catégorie', t.categorie?.nom ?? '-'),
            _detailRow('Type', t.type.name),
            _detailRow(
                'Date',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.parse(t.date))),
            _detailRow('Description', t.description ?? '-'),
            _detailRow('Référence', '#${t.id.substring(0, 8).toUpperCase()}'),
            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Fermer',
                      style: GoogleFonts.poppins(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmerSuppression(t),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Supprimer',
                      style: GoogleFonts.poppins(color: Colors.white),
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

  Widget _detailRow(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.grey, fontSize: 14)),
          Text(valeur,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  void _confirmerSuppression(TransactionModel t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supprimer ?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Cette action est irréversible.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              await ref
                  .read(transactionsProvider.notifier)
                  .deleteTransaction(t.id);
            },
            child: Text('Supprimer',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transState = ref.watch(transactionsProvider);
    final filtrees = _filtrerTransactions(transState.transactions);
    final groupes = _grouperParDate(filtrees);

    return Scaffold(
      appBar: AppHeader(
        title: 'Transactions',
        type: HeaderType.hamburger,
      ),
      body: Column(
        children: [
          // Barre recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _recherche = v),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle:
                    GoogleFonts.poppins(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtres chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 8),

          // Liste groupée
          Expanded(
            child: transState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : filtrees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('💸',
                                style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune transaction',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: groupes.length,
                        itemBuilder: (context, index) {
                          final date =
                              groupes.keys.elementAt(index);
                          final items = groupes[date]!;
                          final totalJour = items.fold(
                              0.0,
                              (sum, t) => t.type.name == 'REVENU'
                                  ? sum + t.montant
                                  : sum - t.montant);

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Séparateur date
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      date,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${totalJour >= 0 ? '+' : ''}${_formatMontant(totalJour)} F',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: totalJour >= 0
                                            ? AppColors.success
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Transactions du jour
                              ...items.map((t) => TransactionItem(
                                    title: t.description ??
                                        t.categorie?.nom ??
                                        'Transaction',
                                    date: DateFormat('HH:mm').format(
                                        DateTime.parse(t.date)),
                                    amount: t.montant,
                                    isIncome: t.type.name == 'REVENU',
                                    emoji: t.categorie?.icone,
                                    onTap: () => _showDetail(t), icon: null,
                                  )),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
