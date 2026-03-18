class RequestCompletedModel {
  final List<String> images;
  final String location;
  final String landmark;
  final String description;
  final String createdAt;

  RequestCompletedModel({
    required this.images,
    required this.location,
    required this.landmark,
    required this.description,
    required this.createdAt,
  });
}