class StreamModel {
  final bool live;
  final String type;
  final String streamUrl;

  StreamModel({
    required this.live,
    required this.type,
    required this.streamUrl,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      live: json["live"] ?? false,
      type: json["type"] ?? "video",
      streamUrl: json["url"] ?? "",   // <-- correct field
    );
  }
}
