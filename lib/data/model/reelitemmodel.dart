class ReelItem {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final double duration;

  // UI fields
  String username;
  String userProfilePic;
  String caption;
  String musicName;

  int likesCount;
  bool isLiked;

  DateTime createdAt; // 🔥 REQUIRED FOR "time ago"

  ReelItem({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.createdAt,

    this.username = "",
    this.userProfilePic = "",
    this.caption = "",
    this.musicName = "Original Audio",

    this.likesCount = 0,
    this.isLiked = false,
  });

  factory ReelItem.fromJson(Map<String, dynamic> json) {
    final user = json["user"] ?? {};

    // 🔍 DEBUG (keep this for now)
    // print(
    //   "📦 Reel → id:${json["id"]}, desc:${json["description"]}, likes:${json["likes"]}, isLiked:${json["is_liked"]}"
    // );

    return ReelItem(
      id: json["id"] ?? "",
      videoUrl: json["video_url"] ?? "",
      thumbnailUrl: json["thumbnail_url"] ?? "",
      duration: (json["duration_seconds"] as num?)?.toDouble() ?? 0.0,

      // ✅ USERNAME (backend uses user_name)
      username: json["user_name"] ??
          user["username"] ??
          json["owner_name"] ??
          "",

      // ✅ PROFILE PIC (safe fallback)
      userProfilePic: json["user_profile_pic"] ??
          user["profile_pic"] ??
          user["image"] ??
          "",

      // ✅ THIS IS THE MAIN FIX
      // backend sends "description", not "caption"
      caption: _normalizeCaption(json["description"]),


      musicName: json["music_name"] ?? "Original Audio",

      likesCount: json["likes"] ?? json["likes_count"] ?? 0,
      isLiked: json["is_liked"] ?? false,

      // ✅ CREATED TIME
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}

String _normalizeCaption(dynamic value) {
  if (value == null) return "";
  if (value is String && value.trim().isEmpty) return "";
  return value.toString();
}

