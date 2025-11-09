class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final String dob;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dob,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dob': dob,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
    );
  }
}
