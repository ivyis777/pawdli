
class GetUserProfileModel {
  final int id;
  final String password;
  final String username;
  final String name;
  final String gender;
  final String address;
  final int? age;
  final String? dob;
  final String mobile;
  final String email;
  final int? pincode;
  final String? bio;
  final String? profilePicture;
  final String? registeredAt;
  final String? lastLogin;
  final String city;
  final String country;
  final String state;
  final bool throughGoogle;
  final String? fcmToken;
  final bool isActive;
  final String? updatedAt;
  final String? updatedBy;
  final String currencyPreference;

GetUserProfileModel({
    required this.id,
    required this.password,
    required this.username,
    required this.name,
    required this.gender,
    required this.address,
    this.age,
    this.dob,
    required this.mobile,
    required this.email,
    this.pincode,
    this.bio,
    this.profilePicture,
    this.registeredAt,
    this.lastLogin,
    required this.city,
    required this.country,
    required this.state,
    required this.throughGoogle,
    this.fcmToken,
    required this.isActive,
    this.updatedAt,
    this.updatedBy,
    required this.currencyPreference,
  });

  factory GetUserProfileModel.fromJson(Map<String, dynamic> json) {
    return GetUserProfileModel(
      id: json['id'],
      password: json['password'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      age: json['age'],
      dob: json['dob'],
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      pincode: json['pincode'],
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      registeredAt: json['registeredat'],
      lastLogin: json['lastlogin'],
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      throughGoogle: json['through_google'] ?? false,
      fcmToken: json['fcm_token'] == "null" ? null : json['fcm_token'],
      isActive: json['is_active'] ?? false,
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'],
      currencyPreference: json['currency_preference'] ?? 'INR',
    );
  }
}

