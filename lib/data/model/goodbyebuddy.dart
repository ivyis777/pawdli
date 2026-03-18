class GoodByeBuddyModel {
  int? id;
  String? location;
  String? landmark;
  List<String>? images;
  String? description;
  String? createdAt;
  int? createdBy;

  GoodByeBuddyModel({
    this.id,
    this.location,
    this.landmark,
    this.images,
    this.description,
    this.createdAt,
    this.createdBy,
  });

  GoodByeBuddyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    location = json['location'];
    landmark = json['landmark'];
    images = json['images'] != null
        ? List<String>.from(json['images'])
        : [];
    description = json['description'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'landmark': landmark,
      'images': images,
      'description': description,
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}
