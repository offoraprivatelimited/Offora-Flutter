class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final String dob;
  final String role; // 'user' or 'shopowner'
  final String approvalStatus; // 'approved', 'pending', 'rejected'
  final String? rejectionReason;
  final String businessName;
  final String contactPerson;
  final String phoneNumber;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dob,
    required this.role,
    required this.approvalStatus,
    this.rejectionReason,
    required this.businessName,
    required this.contactPerson,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => toMap();

  // Returns true if the user is approved (for dashboard logic)
  bool get isApproved => approvalStatus == 'approved';
  // For UI compatibility in rejection_page.dart
  String get rejectionReasonDisplay => rejectionReason ?? '';
  // For UI compatibility in pending_approval_page.dart
  // (businessName, contactPerson, phoneNumber already present)

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dob': dob,
      'role': role,
      'approvalStatus': approvalStatus,
      'rejectionReason': rejectionReason,
      'businessName': businessName,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
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
      role: map['role'] ?? 'user',
      approvalStatus: map['approvalStatus'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      businessName: map['businessName'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
