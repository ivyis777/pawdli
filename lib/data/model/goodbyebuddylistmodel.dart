class GoodbyeRequestDetailsModel {

  int? id;
  String? location;
  String? landmark;
  String? description;
  String? status;
  String? createdAt;
  double? latitude;
  double? longitude;
  List<String>? images;
  List<String>? adminImages;
  String? adminDescription;

  GoodbyeRequestDetailsModel({
    this.id,
    this.location,
    this.landmark,
    this.description,
    this.status,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.images,
    this.adminImages,
    this.adminDescription
  });

  factory GoodbyeRequestDetailsModel.fromJson(Map<String, dynamic> json) {

    return GoodbyeRequestDetailsModel(
      id: json['id'],
      location: json['location'],
      landmark: json['landmark'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],

      // 🔴 FIX FOR STRING LAT/LNG
      latitude: json['latitude'] != null && json['latitude'].toString().isNotEmpty
          ? double.tryParse(json['latitude'].toString())
          : null,

      longitude: json['longitude'] != null && json['longitude'].toString().isNotEmpty
          ? double.tryParse(json['longitude'].toString())
          : null,

      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      adminImages: json['admin_images'] != null
            ? List<String>.from(json['admin_images'])
            : [],
            adminDescription: json['admin_description'],
    );
  }
}