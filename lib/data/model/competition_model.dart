class CompetitionModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isActive;

  CompetitionModel({
    required this.id,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.isActive,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      startDateTime: DateTime.parse(json['start_datetime']), // ✅ FIX
      endDateTime: DateTime.parse(json['end_datetime']),     // ✅ FIX
      isActive: json['is_active'] == true,
    );
  }
}
