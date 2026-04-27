class UserAccount {
  final String email;
  String username;
  String password;
  final String? phoneNumber;
  final bool isGoogleUser;
  bool isAdmin;

  UserAccount({
    required this.email,
    required this.username,
    required this.password,
    this.phoneNumber,
    this.isGoogleUser = false,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
      'isGoogleUser': isGoogleUser,
      'isAdmin': isAdmin,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      email: map['email'],
      username: map['username'],
      password: map['password'],
      phoneNumber: map['phoneNumber'],
      isGoogleUser: map['isGoogleUser'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
    );
  }
}
