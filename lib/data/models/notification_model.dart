enum NotificationType { BUDGET, TRANSACTION, OBJECTIF, SYSTEME }

class NotificationModel {
  final String id;
  final String titre;
  final String message;
  final NotificationType type;
  final bool estLu;
  final DateTime dateCreation;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.estLu,
    required this.dateCreation,
  });

  // ================= JSON → OBJECT =================
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      titre: json['titre'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.SYSTEME,
      ),
      estLu: json['estLu'] ?? false,
      // ✅ dateCreation pas createdAt
      dateCreation: DateTime.parse(json['dateCreation']),
    );
  }

  // ================= OBJECT → JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'message': message,
      'type': type.name,
      'estLu': estLu,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
