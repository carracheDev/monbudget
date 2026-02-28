import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monbudget/core/constants/app_colors.dart';
import 'package:monbudget/features/epargne/epargne_provider.dart';
import 'package:monbudget/shared/widgets/app_drawer.dart';
import 'package:monbudget/shared/widgets/app_header.dart';
import 'package:monbudget/shared/widgets/app_toast.dart';

class EpargneScreen extends ConsumerStatefulWidget {
  const EpargneScreen({super.key});

  @override
  ConsumerState<EpargneScreen> createState() => _EpargneScreenState();
}

class _EpargneScreenState extends ConsumerState<EpargneScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(epargneProvider.notifier).getObjectifs();
    });
  }

  // ===== CARTE ÉPARGNE TOTALE =====
  Widget _buildCarteEpargne(List objectifs) {
    final total = objectifs.fold(
      0.0,
      (sum, o) => sum + (o.montantActuel as double),
    );

    final actifs = objectifs
        .where((o) => o.statut.toString().split('.').last == 'ACTIF')
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Épargne Totale',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat('#,###', 'fr_FR').format(total)} F',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$actifs objectif${actifs > 1 ? 's' : ''} actif${actifs > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Text('🐷', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  // ===== CARTE OBJECTIF =====
  Widget _buildCarteObjectif(dynamic objectif) {
    final pourcentage = (objectif.montantActuel / objectif.montantCible * 100)
        .clamp(0.0, 100.0);
    final isTermine = objectif.statut.toString().split('.').last == 'TERMINE';
    final color = isTermine ? AppColors.success : const Color(0xFF6C63FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Row(
            children: [
              Text(objectif.icone, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      objectif.nom,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Objectif : ${NumberFormat('#,###', 'fr_FR').format(objectif.montantCible)} F',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge pourcentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isTermine
                      ? 'Terminé 🎉'
                      : '${pourcentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pourcentage / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Montant + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${NumberFormat('#,###', 'fr_FR').format(objectif.montantActuel)} F',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'Échéance : ${DateFormat('dd/MM/yyyy').format(objectif.dateEcheance)}',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isTermine
                      ? null
                      : () => _showAjouterContribution(objectif),
                  child: Text(
                    'Ajouter',
                    style: GoogleFonts.poppins(
                      color: isTermine ? Colors.grey : color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => isTermine
                      ? _showDetailTermine(objectif)
                      : _showDetail(objectif),
                  child: Text(
                    'Détails',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== MODALE CRÉER OBJECTIF =====
  void _showCreerObjectif() {
    final nomController = TextEditingController();
    final montantController = TextEditingController();
    DateTime? dateSelectionnee;
    String iconeSelectionnee = '🎯';

    final emojis = [
      '🎯',
      '🏠',
      '🚗',
      '✈️',
      '📱',
      '💻',
      '🎓',
      '💍',
      '🏖️',
      '🏋️',
      '🐷',
      '💰',
      '🎮',
      '📚',
      '🎸',
      '⌚',
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
                // Titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouvel objectif',
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

                // Sélection icône
                Text(
                  'Icône',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((e) {
                    final selected = iconeSelectionnee == e;
                    return GestureDetector(
                      onTap: () => setModalState(() => iconeSelectionnee = e),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: AppColors.primary)
                              : null,
                        ),
                        child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Nom
                Text(
                  'Nom de l\'objectif',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nomController,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Ex: Voyage au Maroc',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Montant cible
                Text(
                  'Montant cible (F CFA)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: montantController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: '500 000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date d'échéance
                Text(
                  'Date d\'échéance',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setModalState(() => dateSelectionnee = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dateSelectionnee != null
                              ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(dateSelectionnee!)
                              : 'Sélectionner une date',
                          style: GoogleFonts.poppins(
                            color: dateSelectionnee != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton créer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          nomController.text.isNotEmpty &&
                              montantController.text.isNotEmpty &&
                              dateSelectionnee != null
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed:
                        nomController.text.isNotEmpty &&
                            montantController.text.isNotEmpty &&
                            dateSelectionnee != null
                        ? () async {
                            Navigator.pop(context);
                            await ref
                                .read(epargneProvider.notifier)
                                .creerObjectif(
                                  nom: nomController.text,
                                  icone: iconeSelectionnee,
                                  montantCible: double.parse(
                                    montantController.text,
                                  ),
                                  dateEcheance: dateSelectionnee!,
                                );
                            if (mounted) {
                              AppToast.show(
                                context,
                                message: 'Objectif créé ✓',
                                type: ToastType.success,
                              );
                            }
                          }
                        : null,
                    child: Text(
                      'Créer l\'objectif',
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

  // ===== MODALE AJOUTER CONTRIBUTION =====
  void _showAjouterContribution(dynamic objectif) {
    final montantController = TextEditingController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajouter à ${objectif.nom}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant (F CFA)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                onPressed: () async {
                  Navigator.pop(context);
                  await ref
                      .read(epargneProvider.notifier)
                      .ajouterContribution(
                        objectifId: objectif.id,
                        montant: double.parse(montantController.text),
                      );
                  if (mounted) {
                    AppToast.show(
                      context,
                      message: 'Contribution ajoutée ✓',
                      type: ToastType.success,
                    );
                  }
                },
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MODALE DÉTAIL =====
  void _showDetail(dynamic objectif) {
    final pourcentage = (objectif.montantActuel / objectif.montantCible * 100)
        .clamp(0.0, 100.0);

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
            Text(objectif.icone, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              objectif.nom,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Épargné',
                  '${NumberFormat('#,###', 'fr_FR').format(objectif.montantActuel)} F',
                  const Color(0xFF6C63FF),
                ),
                _buildStatItem(
                  'Restant',
                  '${NumberFormat('#,###', 'fr_FR').format(objectif.montantCible - objectif.montantActuel)} F',
                  AppColors.primary,
                ),
                _buildStatItem(
                  'Objectif',
                  '${NumberFormat('#,###', 'fr_FR').format(objectif.montantCible)} F',
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pourcentage / 100,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C63FF),
                ),
                minHeight: 10,
              ),
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
                  'Fermer',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MODALE DÉTAIL TERMINÉ =====
  void _showDetailTermine(dynamic objectif) {
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
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              'Félicitations !',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            Text(
              '${objectif.nom} est atteint !',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildBoutonAction(
              label: '📦 Archiver',
              color: Colors.grey,
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(epargneProvider.notifier)
                    .archiverObjectif(objectif.id);
              },
            ),
            const SizedBox(height: 8),
            _buildBoutonAction(
              label: '🎯 Créer un nouvel objectif',
              color: const Color(0xFF6C63FF),
              onTap: () {
                Navigator.pop(context);
                _showCreerObjectif();
              },
            ),
            const SizedBox(height: 8),
            _buildBoutonAction(
              label: '💸 Retirer les fonds',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                AppToast.show(
                  context,
                  message: 'Fonctionnalité bientôt disponible',
                  type: ToastType.info,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBoutonAction({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        child: Text(label, style: GoogleFonts.poppins(color: color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final epargneState = ref.watch(epargneProvider);
    final objectifs = epargneState.objectifs;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppHeader(
        title: 'Mon Épargne',
        type: HeaderType.hamburger,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onNotificationTap: () => context.push('/notifications'),
      ),
      backgroundColor: Colors.grey.shade50,
      body: epargneState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Carte épargne totale
                  _buildCarteEpargne(objectifs),
                  const SizedBox(height: 24),

                  // Section objectifs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Objectifs d\'Épargne',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showCreerObjectif,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        label: Text(
                          'Nouveau',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Liste objectifs
                  if (objectifs.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const Text('🐷', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun objectif d\'épargne',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Créez votre premier objectif !',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...objectifs.map(_buildCarteObjectif),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
