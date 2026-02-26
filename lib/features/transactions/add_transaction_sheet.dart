import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/data/models/transaction_model.dart';
import 'package:monbudget/features/categories/categorie_provider.dart';
import 'package:monbudget/features/transactions/transactions_provider.dart';
import 'package:monbudget/shared/widgets/app_button.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionType _type = TransactionType.DEPENSE;
  String? _categorieId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categorieProvider.notifier).getCategories();
    });
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _montantController.text.isNotEmpty && _categorieId != null;

  Future<void> _enregistrer() async {
    await ref.read(transactionsProvider.notifier).createTransaction(
          montant: double.parse(_montantController.text),
          type: _type,
          categorieId: _categorieId!,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );

    final state = ref.read(transactionsProvider);
    if (state.error != null) {
      if (mounted) {
        AppToast.show(context, message: state.error!, type: ToastType.error);
      }
    } else {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Transaction ajoutée ✓',
          type: ToastType.success,
        );
        Navigator.pop(context);
      }
    }
  }

  void _showAddCategorieDialog() {
  final nomController = TextEditingController();
  final iconeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
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
              labelText: 'Nom de la catégorie',
              hintText: 'Ex: Courses',
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
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed: () async {
            if (nomController.text.isNotEmpty) {
              await ref.read(categorieProvider.notifier).createCategorie(
                    nom: nomController.text,
                    icone: iconeController.text.isEmpty
                        ? '📦'
                        : iconeController.text,
                  );
              if (mounted) Navigator.pop(context);
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
    final categorieState = ref.watch(categorieProvider);
    final transState = ref.watch(transactionsProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre + fermer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nouvelle Transaction',
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

            // Toggle Type
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: TransactionType.values.map((type) {
                  final isSelected = _type == type;
                  final color = type == TransactionType.REVENU
                      ? AppColors.success
                      : type == TransactionType.DEPENSE
                          ? AppColors.primary
                          : AppColors.savings;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Montant
            Text('Montant (F CFA)',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _type == TransactionType.REVENU
                    ? AppColors.success
                    : AppColors.primary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 28,
                  color: Colors.grey.shade300,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Catégorie
            Text('Catégorie',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            categorieState.isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categorieState.categories.map((cat) {
                      final isSelected = _categorieId == cat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _categorieId = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                              color:
                                  isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Après la liste des catégories
GestureDetector(
  onTap: () => _showAddCategorieDialog(),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.add, color: AppColors.primary, size: 16),
        const SizedBox(width: 4),
        Text(
          'Nouvelle',
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontSize: 13,
          ),
        ),
      ],
    ),
  ),
),
            const SizedBox(height: 20),

            // Description
            Text('Description (optionnel)',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Ex: Courses au marché...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton Enregistrer
            AppButton(
              label: 'Enregistrer',
              onPressed: _isFormValid ? _enregistrer : null,
              isLoading: transState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}