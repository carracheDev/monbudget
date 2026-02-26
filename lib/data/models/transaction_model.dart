import 'package:monbudget/data/models/categorie_model.dart';

enum TransactionType { DEPENSE, REVENU, TRANSFERT }

class TransactionModel {
  final String id;
  final String reference;
  final double montant;
  final TransactionType type;
  final String? description;
  final String date;
  final String statut;
  final String categorieId;
  final String compteSourceId;
  final String dateCreation;
  final CategorieModel? categorie;

  TransactionModel({
    required this.id,
    required this.reference,
    required this.montant,
    required this.type,
    this.description,
    required this.date,
    required this.statut,
    required this.categorieId,
    required this.compteSourceId,
    required this.dateCreation,
    this.categorie,
  });

  // ================= JSON → OBJECT =================
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      reference: json['reference'],
      montant: (json['montant'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      date: json['date'],
      statut: json['statut'],
      categorieId: json['categorieId'],
      compteSourceId: json['compteSourceId'],
      dateCreation: json['dateCreation'],
      categorie: json['categorie'] != null 
    ? CategorieModel.fromJson(json['categorie']) 
    : null,
    );
  }

  // ================= OBJECT → JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'montant': montant,
      'type': type.name,
      'description': description,
      'date': date,
      'statut': statut,
      'categorieId': categorieId,
      'compteSourceId': compteSourceId,
      'dateCreation': dateCreation,
      'categorie': categorie,
    };
  }
}
