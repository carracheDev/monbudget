import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monbudget/core/constants/app_colors.dart';

// Modèle de devise
class Devise {
  final String code;
  final String name;
  final String symbol;

  const Devise({required this.code, required this.name, required this.symbol});
}

// Liste des devises disponibles
const List<Devise> devises = [
  Devise(code: 'XOF', name: 'Franc CFA (BCEAO)', symbol: 'F CFA'),
  Devise(code: 'EUR', name: 'Euro', symbol: '€'),
  Devise(code: 'USD', name: 'Dollar américain', symbol: '\$'),
  Devise(code: 'GBP', name: 'Livre sterling', symbol: '£'),
  Devise(code: 'BRL', name: 'Real brésilien', symbol: 'R\$'),
  Devise(code: 'CAD', name: 'Dollar canadien', symbol: 'CA\$'),
  Devise(code: 'CHF', name: 'Franc suisse', symbol: 'CHF'),
  Devise(code: 'JPY', name: 'Yen japonais', symbol: '¥'),
  Devise(code: 'CNY', name: 'Yuan chinois', symbol: '¥'),
];

// Provider pour gérer la devise
final selectedDeviseProvider = StateNotifierProvider<DeviseNotifier, Devise>((
  ref,
) {
  return DeviseNotifier();
});

class DeviseNotifier extends StateNotifier<Devise> {
  DeviseNotifier() : super(devises[0]); // Par défaut: F CFA

  void setDevise(Devise devise) {
    state = devise;
  }
}

class DeviseScreen extends ConsumerWidget {
  const DeviseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDevise = ref.watch(selectedDeviseProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Devise',
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
                const Icon(Icons.currency_exchange, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sélectionnez la devise pour vos transactions',
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

          // Current selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Devise actuelle',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '${currentDevise.name} (${currentDevise.symbol})',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Devise options
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              children: devises.asMap().entries.map((entry) {
                final index = entry.key;
                final devise = entry.value;
                final isSelected = currentDevise.code == devise.code;
                return Column(
                  children: [
                    _buildDeviseOption(
                      context: context,
                      devise: devise,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(selectedDeviseProvider.notifier)
                            .setDevise(devise);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Devise changée: ${devise.name}',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                      },
                    ),
                    if (index < devises.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
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
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Le changement de devise n\'affecte pas les transactions existantes',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviseOption({
    required BuildContext context,
    required Devise devise,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            devise.symbol,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ),
        ),
      ),
      title: Text(
        devise.name,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        devise.code,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: onTap,
    );
  }
}
