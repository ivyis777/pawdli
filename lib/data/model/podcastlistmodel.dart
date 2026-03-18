class PodcastListModel {
  String? message;
  List<PodcastData>? data;

  PodcastListModel({this.message, this.data});

  PodcastListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <PodcastData>[];
      json['data'].forEach((v) {
        data!.add(PodcastData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PodcastData {
  int? podcastId;
  String? title;
  String? description;
  String? coverImage;
  bool? isActive;
  String? createdAt;

  PodcastData({
    this.podcastId,
    this.title,
    this.description,
    this.coverImage,
    this.isActive,
    this.createdAt,
  });

  PodcastData.fromJson(Map<String, dynamic> json) {
    podcastId = json['podcast_id'];
    title = json['title'];
    description = json['description'];
    coverImage = json['cover_image'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'podcast_id': podcastId,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
