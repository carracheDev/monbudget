enum RechargeStatut { EN_COURS, VALIDEE, ECHOUEE, ANNULEE }

class RechargeModel {
  final String id;
  final double montant;
  final String operateur;
  final String numeroTelephone;
  final RechargeStatut statut;
  final DateTime dateCreation;

  RechargeModel({
    required this.id,
    required this.montant,
    required this.operateur,
    required this.numeroTelephone,
    required this.statut,
    required this.dateCreation,
  });

  // ================= JSON → OBJECT =================
  factory RechargeModel.fromJson(Map<String, dynamic> json) {
    return RechargeModel(
      id: json['id'],
      montant: (json['montant'] as num).toDouble(),
      operateur: json['operateur'],
      numeroTelephone: json['numeroTelephone'],
      statut: RechargeStatut.values.firstWhere((e) => e.name == json['statut']),
      dateCreation: DateTime.parse(json['dateCreation']),
    );
  }

  // ================= OBJECT → JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'operateur': operateur,
      'numeroTelephone': numeroTelephone,
      'statut': statut.name,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
