import 'package:monbudget/data/models/categorie_model.dart';

enum TransactionType { DEPENSE, REVENU, TRANSFERT }

class TransactionModel {
  final String id;
  final String reference;
  final double montant;
  final TransactionType type;
  final String? description;
  final DateTime date;        // ✅ DateTime
  final String statut;
  final String categorieId;
  final String compteSourceId;
  final DateTime dateCreation; // ✅ DateTime
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      reference: json['reference'],
      montant: (json['montant'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      date: DateTime.parse(json['date']),             // ✅ parse
      statut: json['statut'],
      categorieId: json['categorieId'],
      compteSourceId: json['compteSourceId'],
      dateCreation: DateTime.parse(json['dateCreation']), // ✅ parse
      categorie: json['categorie'] != null
          ? CategorieModel.fromJson(json['categorie'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'montant': montant,
      'type': type.name,
      'description': description,
      'date': date.toIso8601String(),             // ✅
      'statut': statut,
      'categorieId': categorieId,
      'compteSourceId': compteSourceId,
      'dateCreation': dateCreation.toIso8601String(), // ✅
      'categorie': categorie,
    };
  }
}