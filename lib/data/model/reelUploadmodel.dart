class UploadReelResponse {
  final String? status;
  final String? videoId;
  final double? duration;
  final String? s3Key;
  final String? thumbnailKey;

  UploadReelResponse({
    this.status,
    this.videoId,
    this.duration,
    this.s3Key,
    this.thumbnailKey,
  });

  factory UploadReelResponse.fromJson(Map<String, dynamic> json) {
    return UploadReelResponse(
      status: json["status"],
      videoId: json["video_id"],
      duration: (json["duration"] as num?)?.toDouble(),
      s3Key: json["s3_key"],
      thumbnailKey: json["thumbnail_key"],
    );
  }
}
