class PetPodcastEpisodeModel {
  String? message;
  List<Data>? data;

  PetPodcastEpisodeModel({this.message, this.data});

  PetPodcastEpisodeModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.map((v) => v.toJson()).toList();
    }
    return result;
  }
}

class Data {
  int? episodeId;
  String? title;
  String? description;
  Guest? guest;
  Podcast? podcast;
  String? fileUrl;
  String? fileUrlFull;
  String? thumbnailUrl;
  String? thumbnailUrlFull;
  int? durationMinutes;
  String? price;
  bool? isActive;
  String? uploadedAt;

  Data({
    this.episodeId,
    this.title,
    this.description,
    this.guest,
    this.podcast,
    this.fileUrl,
    this.fileUrlFull,
    this.thumbnailUrl,
    this.thumbnailUrlFull,
    this.durationMinutes,
    this.price,
    this.isActive,
    this.uploadedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    episodeId = json['episode_id'];
    title = json['title'];
    description = json['description'];
    guest = json['guest'] != null ? Guest.fromJson(json['guest']) : null;
    podcast = json['podcast'] != null ? Podcast.fromJson(json['podcast']) : null;
    fileUrl = json['file_url'];
    fileUrlFull = json['file_url_full'];
    thumbnailUrl = json['thumbnail_url'];
    thumbnailUrlFull = json['thumbnail_url_full'];
    durationMinutes = json['duration_minutes'];
    price = json['price'];
    isActive = json['is_active'];
    uploadedAt = json['uploaded_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['episode_id'] = episodeId;
    result['title'] = title;
    result['description'] = description;
    if (guest != null) {
      result['guest'] = guest!.toJson();
    }
    if (podcast != null) {
      result['podcast'] = podcast!.toJson();
    }
    result['file_url'] = fileUrl;
    result['file_url_full'] = fileUrlFull;
    result['thumbnail_url'] = thumbnailUrl;
    result['thumbnail_url_full'] = thumbnailUrlFull;
    result['duration_minutes'] = durationMinutes;
    result['price'] = price;
    result['is_active'] = isActive;
    result['uploaded_at'] = uploadedAt;
    return result;
  }
}

class Guest {
  int? guestId;
  String? name;
  String? email;
  String? contactNumber;
  String? address;
  String? profileImage;
  String? bio;
  bool? isActive;

  Guest({
    this.guestId,
    this.name,
    this.email,
    this.contactNumber,
    this.address,
    this.profileImage,
    this.bio,
    this.isActive,
  });

  Guest.fromJson(Map<String, dynamic> json) {
    guestId = json['guest_id'];
    name = json['name'];
    email = json['email'];
    contactNumber = json['contact_number'];
    address = json['address'];
    profileImage = json['profile_image'];
    bio = json['bio'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['guest_id'] = guestId;
    result['name'] = name;
    result['email'] = email;
    result['contact_number'] = contactNumber;
    result['address'] = address;
    result['profile_image'] = profileImage;
    result['bio'] = bio;
    result['is_active'] = isActive;
    return result;
  }
}

class Podcast {
  int? podcastId;
  String? title;
  String? description;
  String? coverImage;
  bool? isActive;
  String? createdAt;

  Podcast({
    this.podcastId,
    this.title,
    this.description,
    this.coverImage,
    this.isActive,
    this.createdAt,
  });

  Podcast.fromJson(Map<String, dynamic> json) {
    podcastId = json['podcast_id'];
    title = json['title'];
    description = json['description'];
    coverImage = json['cover_image'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['podcast_id'] = podcastId;
    result['title'] = title;
    result['description'] = description;
    result['cover_image'] = coverImage;
    result['is_active'] = isActive;
    result['created_at'] = createdAt;
    return result;
  }
}
