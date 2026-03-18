class Productpromotionmodel {
  final int? id;
  final String? title;
  final String? description;
  final String? url;
  final String? image;   // <-- Universal storage
  final bool? status;
  final DateTime? createdAt;

  Productpromotionmodel({
    this.id,
    this.title,
    this.description,
    this.url,
    this.image,
    this.status,
    this.createdAt,
  });

  factory Productpromotionmodel.fromJson(Map<String, dynamic> json) {
    return Productpromotionmodel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      url: json["url"],
      image: json["image_url"] ?? json["image"],  // 🔥 universal
      status: json["status"],
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "url": url,
      "image": image,
      "status": status,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  String get imageUrl => image ?? "";
}
