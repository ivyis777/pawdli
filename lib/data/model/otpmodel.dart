class OptModel {
  bool? status;
  String? message;
  String? code;
  Data? data;

  OptModel({this.status, this.message, this.code, this.data});

  OptModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? email;
  String? purpose;
  String? expiresAt;

  Data({this.email, this.purpose, this.expiresAt});

  Data.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    purpose = json['purpose'];
    expiresAt = json['expires_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['purpose'] = this.purpose;
    data['expires_at'] = this.expiresAt;
    return data;
  }
}
