class User {
  final String id;
  final String profileImageUrl;

  User({
    required this.id,
    required this.profileImageUrl,
  });

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as String,
      profileImageUrl: json['profile_image_url'] as String,
    );
  }
}
