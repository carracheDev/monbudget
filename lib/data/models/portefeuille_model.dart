class PortefeuilleModel {
  final String id;
  final double solde;
  final String utilisateurId;

  PortefeuilleModel({
    required this.id,
    required this.solde,
    required this.utilisateurId,
  });

  factory PortefeuilleModel.fromJson(Map<String, dynamic> json) {
    return PortefeuilleModel(
      id: json['id'],
      solde: (json['solde'] as num).toDouble(),
      utilisateurId: json['utilisateurId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'solde': solde, 'utilisateurId': utilisateurId};
  }
}
