class ParametresModel {
  final String theme; // light / dark
  final String langue; // fr / en
  final bool biometrie;
  final bool notificationsPush;
  final bool notificationsEmail;

  ParametresModel({
    required this.theme,
    required this.langue,
    required this.biometrie,
    required this.notificationsPush,
    required this.notificationsEmail,
  });

  factory ParametresModel.fromJson(Map<String, dynamic> json) {
    return ParametresModel(
      theme: json['theme'],
      langue: json['langue'],
      biometrie: json['biometrie'],
      notificationsPush: json['notificationsPush'],
      notificationsEmail: json['notificationsEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'langue': langue,
      'biometrie': biometrie,
      'notificationsPush': notificationsPush,
      'notificationsEmail': notificationsEmail,
    };
  }

  // Optionnel mais pro
  ParametresModel copyWith({
    String? theme,
    String? langue,
    bool? biometrie,
    bool? notificationsPush,
    bool? notificationsEmail,
  }) {
    return ParametresModel(
      theme: theme ?? this.theme,
      langue: langue ?? this.langue,
      biometrie: biometrie ?? this.biometrie,
      notificationsPush:
          notificationsPush ?? this.notificationsPush,
      notificationsEmail:
          notificationsEmail ?? this.notificationsEmail,
    );
  }
}