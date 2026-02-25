import 'package:monbudget/data/models/categorie_model.dart';

enum BudgetPeriode { MENSUEL, HEBDOMADAIRE, ANNUEL }

class BudgetModel {
  final String id;
  final double montantLimite;
  final BudgetPeriode periode;
  final double alerteSeuil;
  final bool alerteEnvoyee;
  final bool estActif;
  final String categorieId;
  final CategorieModel? categorie;

  BudgetModel({
    required this.id,
    required this.montantLimite,
    required this.periode,
    required this.alerteSeuil,
    required this.alerteEnvoyee,
    required this.estActif,
    required this.categorieId,
    this.categorie,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      montantLimite: (json['montantLimite'] as num).toDouble(),
      periode: BudgetPeriode.values.firstWhere(
        (e) => e.name == json['periode'],
      ),
      alerteSeuil: (json['alerteSeuil'] as num).toDouble(),
      alerteEnvoyee: json['alerteEnvoyee'],
      estActif: json['estActif'],
      categorieId: json['categorieId'],
      categorie: json['categorie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montantLimite': montantLimite,
      'periode': periode.name,
      'alerteSeuil': alerteSeuil,
      'alerteEnvoyee': alerteEnvoyee,
      'estActif': estActif,
      'categorieId': categorieId,
      'categorie': categorie,
    };
  }
}
