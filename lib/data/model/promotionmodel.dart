class PromotionModel {
  final int? id;
  final String? image;
  final String? url;
  final String? title;
  final String? description;
  final bool? status;
  final DateTime? createdAt;

  PromotionModel({
    this.id,
    this.image,
    this.url,
    this.title,
    this.description,
    this.status,
    this.createdAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'],
      image: json['image'],
      url: json['url'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'url': url,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// ✅ FINAL IMAGE URL (safe for UI)
  String get imageUrl {
    if (image == null || image!.trim().isEmpty) {
      return "";
    }

    final img = image!.trim();

    // Already full URL
    if (img.startsWith("http://") || img.startsWith("https://")) {
      return img;
    }

    // Base64 image
    if (img.startsWith("data:image")) {
      return img;
    }

    // Relative path from backend
    return "https://app.pawdli.com/$img";
  }
}
