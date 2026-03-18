class UpdateProfileModel {
  int? id;
  String? password;
  String? lastLogin;
  String? username;
  String? name;
  String? gender;
  String? address;
  int? age;
  String? dob;
  String? mobile;
  String? email;
  int? pincode;
  String? bio;
  String? profilePicture;
  String? registeredat;
  String? lastlogin;
  String? city;
  String? country;
  String? state;
  bool? throughGoogle;
  String? fcmToken;
  bool? isActive;
  String? updatedAt;
  String? updatedBy;
  String? currencyPreference;
  String? agoraUid;
  bool? onlineStatus;

  UpdateProfileModel({
    this.id,
    this.password,
    this.lastLogin,
    this.username,
    this.name,
    this.gender,
    this.address,
    this.age,
    this.dob,
    this.mobile,
    this.email,
    this.pincode,
    this.bio,
    this.profilePicture,
    this.registeredat,
    this.lastlogin,
    this.city,
    this.country,
    this.state,
    this.throughGoogle,
    this.fcmToken,
    this.isActive,
    this.updatedAt,
    this.updatedBy,
    this.currencyPreference,
    this.agoraUid,
    this.onlineStatus,
  });

  UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    password = json['password'];
    lastLogin = json['last_login'];
    username = json['username'];
    name = json['name'];
    gender = json['gender'];
    address = json['address'];
    age = json['age'];
    dob = json['dob'];
    mobile = json['mobile'];
    email = json['email'];
    pincode = json['pincode'];
    bio = json['bio'];
    profilePicture = json['profile_picture'];
    registeredat = json['registeredat'];
    lastlogin = json['lastlogin'];
    city = json['city'];
    country = json['country'];
    state = json['state'];
    throughGoogle = json['through_google'];
    fcmToken = json['fcm_token'];
    isActive = json['is_active'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    currencyPreference = json['currency_preference'];
    agoraUid = json['agora_uid'];
    onlineStatus = json['online_status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'last_login': lastLogin,
      'username': username,
      'name': name,
      'gender': gender,
      'address': address,
      'age': age,
      'dob': dob,
      'mobile': mobile,
      'email': email,
      'pincode': pincode,
      'bio': bio,
      'profile_picture': profilePicture,
      'registeredat': registeredat,
      'lastlogin': lastlogin,
      'city': city,
      'country': country,
      'state': state,
      'through_google': throughGoogle,
      'fcm_token': fcmToken,
      'is_active': isActive,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
      'currency_preference': currencyPreference,
      'agora_uid': agoraUid,
      'online_status': onlineStatus,
    };
  }
}
