class SignupModel {
  bool? status;
  String? message;
  String? code;
  SignupData? data;

  SignupModel({this.status, this.message, this.code, this.data});

  SignupModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];
    data = json['data'] != null ? SignupData.fromJson(json['data']) : null;
  }
}

class SignupData {
  int? userId;
  String? email;
  String? username;
  String? name; // ✅ ADD THIS
  Tokens? tokens;

  SignupData({
    this.userId,
    this.email,
    this.username,
    this.name,
    this.tokens,
  });

  SignupData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    email = json['email'];
    username = json['username'];
    name = json['name']; // ✅ PARSE THIS
    tokens =
        json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null;
  }
}

class Tokens {
  String? access;
  String? refresh;

  Tokens({this.access, this.refresh});

  Tokens.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    refresh = json['refresh'];
  }
}
