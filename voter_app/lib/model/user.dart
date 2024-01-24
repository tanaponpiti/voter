class User {
  String id;
  String username;
  String password;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'],
      username: json['Username'],
      password: json['Password'],
      name: json['Name'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Username': username,
      'Password': password,
      'Name': name,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }
}
