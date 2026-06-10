class User {
  final String id;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({required this.id, required this.email, required this.createdAt, required this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  User copyWith({String? id, String? email, DateTime? createdAt, DateTime? updatedAt}) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
