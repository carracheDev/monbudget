class UserModel {
  final String id;
  final String nomComplet;
  final String email;

  UserModel({required this.id, required this.nomComplet, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nomComplet: json['nomComplet'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nomComplet': nomComplet, 'email': email};
  }
}
