enum CategorieType {
  DEPENSE,
  REVENU,
  TRANSFERT,
}

class CategorieModel {
  final String id;
  final String nom;
  final String icone;
  final String couleur;
  final CategorieType type;
  final bool estDefaut;

  CategorieModel({
    required this.id,
    required this.nom,
    required this.icone,
    required this.couleur,
    required this.type,
    required this.estDefaut,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      id: json['id'],
      nom: json['nom'],
      icone: json['icone'],
      couleur: json['couleur'],
      type: CategorieType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      estDefaut: json['estDefaut'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'icone': icone,
      'couleur': couleur,
      'type': type.name,
      'estDefaut': estDefaut,
    };
  }
}