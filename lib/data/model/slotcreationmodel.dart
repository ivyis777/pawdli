class SlotPageModel {
  String? message;
  String? date;
  List<Data>? data;

  SlotPageModel({
    this.message,
    this.date,
    this.data,
  });

  SlotPageModel.fromJson(Map<String, dynamic> json) {
    message = json['message']?.toString();
    date = json['date']?.toString();

    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List)
          .map((v) => Data.fromJson(v))
          .toList();
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'date': date,
        'data': data?.map((v) => v.toJson()).toList(),
      };
}

class Data {
  int? slotId;
  int? radiostation;
  String? day;
  String? date;

  String? startTime;
  String? endTime;

  String? amount;
  bool? isAvailable;

  String? createdAt;
  String? updatedAt;
  String? createdBy;
  bool? isActive;

  /// 🆕 Parsed helpers (used for live slot checks)
  DateTime? dateTime;
  DateTime? startDateTime;
  DateTime? endDateTime;

  Data({
    this.slotId,
    this.radiostation,
    this.day,
    this.date,
    this.startTime,
    this.endTime,
    this.amount,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.isActive,
  }) {
    _parseDateTimes();
  }

  Data.fromJson(Map<String, dynamic> json) {
    slotId = _toInt(json['slot_id']);
    radiostation = _toInt(json['radiostation']);
    day = json['day']?.toString();
    date = json['date']?.toString();
    startTime = json['start_time']?.toString();
    endTime = json['end_time']?.toString();
    amount = json['amount']?.toString();
    isAvailable = _toBool(json['is_available']);
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    createdBy = json['created_by']?.toString();
    isActive = _toBool(json['is_active']);

    _parseDateTimes();
  }

  /// 🔹 Parse Date + Time into DateTime safely
  void _parseDateTimes() {
    if (date != null) {
      dateTime = DateTime.tryParse(date!);
    }

    if (date != null && startTime != null) {
      startDateTime = DateTime.tryParse("$date $startTime");
    }

    if (date != null && endTime != null) {
      endDateTime = DateTime.tryParse("$date $endTime");
    }
  }

  /// 🔹 Slot time display helper
  String get slotTime {
    if (startTime != null && endTime != null) {
      return "$startTime - $endTime";
    }
    return "Time not available";
  }

  /// 🔹 Live-slot helper (you already use this logic elsewhere)
  bool get isLiveNow {
    if (startDateTime == null || endDateTime == null) return false;
    final now = DateTime.now();
    return now.isAfter(startDateTime!) && now.isBefore(endDateTime!);
  }

  Map<String, dynamic> toJson() => {
        'slot_id': slotId,
        'radiostation': radiostation,
        'day': day,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'amount': amount,
        'is_available': isAvailable,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'created_by': createdBy,
        'is_active': isActive,
      };

  // ----------------- SAFE PARSERS -----------------

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString() == 'true';
  }
}
