class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }
}
