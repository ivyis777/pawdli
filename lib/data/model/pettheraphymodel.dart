class PetTherapyModel {
  final String? message;
  final List<PetTherapy>? data;

  PetTherapyModel({this.message, this.data});

  factory PetTherapyModel.fromJson(Map<String, dynamic> json) {
    return PetTherapyModel(
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((item) => PetTherapy.fromJson(item))
          .toList(),
    );
  }
}
class PetTherapy {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final String? location;
  final List<GalleryImage>? galleryImages;

  PetTherapy({
    this.id,
    this.name,
    this.description,
    this.image,
    this.location,
    this.galleryImages,
  });

  factory PetTherapy.fromJson(Map<String, dynamic> json) {
    return PetTherapy(
      id: json['pettherapy_id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      location: json['location'],
      galleryImages: (json['gallery_images'] as List<dynamic>?)
          ?.map((e) => GalleryImage.fromJson(e))
          .toList(),
    );
  }

  // 🔑 Helper getter → returns only URL strings
  List<String> get galleryImageUrls =>
      galleryImages?.map((g) => g.image ?? "").toList() ?? [];
}

class GalleryImage {
  final int? id;
  final String? image;

  GalleryImage({this.id, this.image});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['gallery_id'],
      image: json['image'],
    );
  }
}

