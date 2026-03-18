class LanguageCreationModel {
  String? message;
  List<String>? languages;

  LanguageCreationModel({this.message, this.languages});

  LanguageCreationModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    languages = json['languages'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['languages'] = this.languages;
    return data;
  }
}
