import 'package:flutter/material.dart';

class ProgramListModel {
  String? message;
  int? bookedSlotsCount;
  String? date;
  List<Data>? data;

  ProgramListModel({
    this.message,
    this.bookedSlotsCount,
    this.date,
    this.data,
  });

  ProgramListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] as String?;
    bookedSlotsCount = json['booked_slots_count'] as int?;
    date = json['date'] as String?;
    if (json['data'] != null) {
      data = List<Data>.from(
        json['data'].map((v) => Data.fromJson(v)),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'booked_slots_count': bookedSlotsCount,
        'date': date,
        'data': data?.map((v) => v.toJson()).toList(),
      };
}

class Data {
  /// 🔹 Session type: live | recorded
  String? type;

  int? bookingId;
  int? slotId;

  /// Slot time like "10:00 - 10:30"
  String? slotTime;

  String? startTime;
  String? endTime;

  String? programName;
  String? programDescription;

  /// 🔹 Audio | Video
  String? programType;

  List<String>? language;
  String? date;
  String? amount;

  int? userId;
  String? username;

  String? createdAt;
  bool? isSubscribed;
  bool? isHost;

  /// ✅ LIVE session support
  int? sessionId;

  /// ✅ RECORDED session support
  String? recordedUrl;

  DateTime? dateTime;

  Data({
    this.type,
    this.bookingId,
    this.slotId,
    this.slotTime,
    this.startTime,
    this.endTime,
    this.programName,
    this.programDescription,
    this.programType,
    this.language,
    this.date,
    this.amount,
    this.userId,
    this.username,
    this.createdAt,
    this.isSubscribed,
    this.isHost,
    this.sessionId,
    this.recordedUrl,
  }) {
    if (date != null) {
      dateTime = DateTime.tryParse(date!);
    }
  }

  /// 🔹 Custom getter for displaying time
  String get programTime =>
      (startTime != null && endTime != null)
          ? "$startTime - $endTime"
          : slotTime ?? "Time not available";

  /// 🔹 Optional helper
  int? get dateEpoch => dateTime?.millisecondsSinceEpoch;

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    bookingId = json['booking_id'] as int?;
    slotId = json['slot_id'] as int?;
    slotTime = json['slot_time'] as String?;
    startTime = json['start_time'] as String?;
    endTime = json['end_time'] as String?;
    programName = json['program_name'] as String?;
    programDescription = json['program_description'] as String?;
    programType = json['program_type'] as String?;

    // 🚑 TEMP FIX: Backend not sending program type
if (type == null) {
  debugPrint("⚠️ BACKEND MISSING 'type' → DEFAULTING TO LIVE");
  type = "live";
}


    // Language can be string or list
    if (json['language'] != null) {
      if (json['language'] is String) {
        language = [json['language'] as String];
      } else if (json['language'] is List) {
        language = (json['language'] as List).cast<String>();
      }
    }

    date = json['date'] as String?;
    if (date != null) {
      dateTime = DateTime.tryParse(date!);
    }

    amount = json['amount'] as String?;
    userId = json['user_id'] as int?;
    username = json['username'] as String?;
    createdAt = json['created_at'] as String?;
    isSubscribed = json['is_subscribed'] as bool?;
    isHost = json['is_host'] as bool?;

    /// ✅ NEW FIELDS
    sessionId = json['session_id'] as int?;
    recordedUrl = json['recorded_url'] as String?;
    
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'booking_id': bookingId,
        'slot_id': slotId,
        'slot_time': slotTime,
        'start_time': startTime,
        'end_time': endTime,
        'program_name': programName,
        'program_description': programDescription,
        'program_type': programType,
        'language': language,
        'date': date,
        'amount': amount,
        'user_id': userId,
        'username': username,
        'created_at': createdAt,
        'is_subscribed': isSubscribed,
        'is_host': isHost,

        /// ✅ NEW FIELDS
        'session_id': sessionId,
        'recorded_url': recordedUrl,
      };
      
}
