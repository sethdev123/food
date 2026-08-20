enum UserRole {
  customer,
  seller,
  admin,
}

class User {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String address;
  final UserRole role;
  final String profilePic;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber = '',
    this.address = '',
    required this.role,
    this.profilePic = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role.toString(),
      'profilePic': profilePic,
    };
  }

  /// Parse from local SharedPreferences storage (old format)
  factory User.fromMap(Map<String, dynamic> map) {
    UserRole role;
    switch (map['role']) {
      case 'UserRole.admin':
      case 'admin':
        role = UserRole.admin;
        break;
      case 'UserRole.seller':
      case 'seller':
        role = UserRole.seller;
        break;
      default:
        role = UserRole.customer;
    }
    return User(
      id: map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone_number'] ?? '',
      address: map['address'] ?? '',
      role: role,
      profilePic: map['profilePic'] ?? '',
    );
  }

  /// Parse from Laravel API JSON response (snake_case keys, numeric id)
  factory User.fromApiMap(Map<String, dynamic> map) {
    UserRole role;
    switch (map['role']) {
      case 'admin':
        role = UserRole.admin;
        break;
      case 'seller':
        role = UserRole.seller;
        break;
      default:
        role = UserRole.customer;
    }
    return User(
      id: map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      address: map['address'] ?? '',
      role: role,
      profilePic: map['profile_pic'] ?? '',
    );
  }

  User copyWith({
    String? name,
    String? phoneNumber,
    String? address,
    String? profilePic,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}
