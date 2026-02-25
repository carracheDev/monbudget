enum CompteType { PRINCIPAL, EPARGNE, MOBILE_MONEY, BANQUE, CASH, AUTRE }

class CompteModel {
  final String id;
  final String nom;
  final CompteType type;
  final double solde;
  final String devise;
  final bool estActif;
  final bool estDefaut;
  final String? operateur;

  CompteModel({
    required this.id,
    required this.nom,
    required this.type,
    required this.solde,
    required this.devise,
    required this.estActif,
    required this.estDefaut,
    this.operateur,
  });

  factory CompteModel.fromJson(Map<String, dynamic> json) {
    return CompteModel(
      id: json['id'],
      nom: json['nom'],
      type: CompteType.values.firstWhere((e) => e.name == json['type']),
      solde: (json['solde'] as num).toDouble(),
      devise: json['devise'],
      estActif: json['estActif'],
      estDefaut: json['estDefaut'],
      operateur: json['operateur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type.name,
      'solde': solde,
      'devise': devise,
      'estActif': estActif,
      'estDefaut': estDefaut,
      'operateur': operateur,
    };
  }
}
