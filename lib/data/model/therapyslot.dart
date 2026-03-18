class TherapySlotPageModel {
  final List<TherapySlot> data;

  TherapySlotPageModel({required this.data});

  factory TherapySlotPageModel.fromJson(Map<String, dynamic> json) {
    return TherapySlotPageModel(
      data: (json['data'] as List)
          .map((item) => TherapySlot.fromJson(item))
          .toList(),
    );
  }
}

class TherapySlot {
  final int? slotId;
  final int? radiostation;
  final String? day;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? amount;
  final bool? isAvailable;

  TherapySlot({
    this.slotId,
    this.radiostation,
    this.day,
    this.date,
    this.startTime,
    this.endTime,
    this.amount,
    this.isAvailable,
  });

  factory TherapySlot.fromJson(Map<String, dynamic> json) {
    return TherapySlot(
      slotId: json['slot_id'],
      radiostation: json['pettherapy'], // fixed key
      day: json['day'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      amount: json['amount'],
      isAvailable: json['is_available'],
    );
  }
}
