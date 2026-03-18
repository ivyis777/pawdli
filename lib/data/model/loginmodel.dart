class LoginModel {
  bool? status;
  String? message;
  String? code;
  Data? data;

  LoginModel({this.status, this.message, this.code, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    final dynamic statusValue = json['status'];
    if (statusValue is bool) {
      status = statusValue;
    } else if (statusValue is String) {
      status = statusValue.toLowerCase() == 'true';
    } else if (statusValue is int) {
      status = statusValue == 1;
    } else {
      status = false;
    }

    message = json['message'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    dataMap['message'] = message;
    dataMap['code'] = code;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class Data {
  Tokens? tokens;
  int? userId;
  String? email;
  String? username;
  String? name;
  String? mobile;
  String? profilePicture;
  bool? isSuperuser;
  bool? isStaff;

  Data({
    this.tokens,
    this.userId,
    this.email,
    this.username,
    this.name,
    this.mobile,
    this.profilePicture,
    this.isSuperuser,
    this.isStaff
  });

  Data.fromJson(Map<String, dynamic> json) {
    tokens = json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null;
    userId = json['user_id'];
    email = json['email'];
    username = json['username'];
    name = json['name'];
    mobile = json['mobile'];
    profilePicture = json['profile_picture'];
    isSuperuser = json['is_superuser'];
    isStaff = json['is_staff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    if (tokens != null) {
      dataMap['tokens'] = tokens!.toJson();
    }
    dataMap['user_id'] = userId;
    dataMap['email'] = email;
    dataMap['username'] = username;
    dataMap['name'] = name;
    dataMap['mobile'] = mobile;
    dataMap['profile_picture'] = profilePicture;
    dataMap['is_superuser'] = isSuperuser;
    dataMap['is_staff'] = isStaff;
    return dataMap;
  }
}

class Tokens {
  String? refresh;
  String? access;

  Tokens({this.refresh, this.access});

  Tokens.fromJson(Map<String, dynamic> json) {
    refresh = json['refresh'];
    access = json['access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['refresh'] = refresh;
    dataMap['access'] = access;
    return dataMap;
  }
}
