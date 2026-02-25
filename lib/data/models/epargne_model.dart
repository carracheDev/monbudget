enum EpargneStatut { EN_COURS, TERMINEE, ANNULEE }

class EpargneModel {
  final String id;
  final String nom;
  final String icone;
  final double montantCible;
  final double montantActuel;
  final DateTime dateEcheance;
  final EpargneStatut statut;

  EpargneModel({
    required this.id,
    required this.nom,
    required this.icone,
    required this.montantCible,
    required this.montantActuel,
    required this.dateEcheance,
    required this.statut,
  });

  // ================= JSON → OBJECT =================
  factory EpargneModel.fromJson(Map<String, dynamic> json) {
    return EpargneModel(
      id: json['id'],
      nom: json['nom'],
      icone: json['icone'],
      montantCible: (json['montantCible'] as num).toDouble(),
      montantActuel: (json['montantActuel'] as num).toDouble(),
      dateEcheance: DateTime.parse(json['dateEcheance']),
      statut: EpargneStatut.values.firstWhere((e) => e.name == json['statut']),
    );
  }

  // ================= OBJECT → JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'icone': icone,
      'montantCible': montantCible,
      'montantActuel': montantActuel,
      'dateEcheance': dateEcheance.toIso8601String(),
      'statut': statut.name,
    };
  }
}
