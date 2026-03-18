class AllPetRadioModel {
  String? message;
  List<Data>? data;

  AllPetRadioModel({this.message, this.data});

  AllPetRadioModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? radiostationId;
  String? name;
  String? description;
  String? language;
  String? subscriptionAmount;
  bool? status;
  bool? isActive;
  bool? subscribed;
  String? image;

  Data(
      {this.radiostationId,
      this.name,
      this.description,
      this.language,
      this.subscriptionAmount,
      this.status,
      this.isActive,
      this.subscribed,
      this.image});

  Data.fromJson(Map<String, dynamic> json) {
    radiostationId = json['radiostation_id'];
    name = json['name'];
    description = json['description'];
    language = json['language'];
    subscriptionAmount = json['subscription_amount'];
    status = json['status'];
    isActive = json['is_active'];
    subscribed = json['subscribed'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['radiostation_id'] = this.radiostationId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['language'] = this.language;
    data['subscription_amount'] = this.subscriptionAmount;
    data['status'] = this.status;
    data['is_active'] = this.isActive;
    data['subscribed'] = this.subscribed;
    data['image'] = this.image;
    return data;
  }
}
