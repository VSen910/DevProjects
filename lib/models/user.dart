class User {
  String? name;
  String email;
  String? password;
  String? picturePath;
  List? following;
  List? followers;

  User({
    required this.email,
    this.password,
    this.name,
    this.picturePath,
    this.following,
    this.followers,
  });

  Map<String, dynamic> toRegisterJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toLoginJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      picturePath: json['picturePath'],
      following: json['following'],
      followers: json['followers'],
    );
  }
}
