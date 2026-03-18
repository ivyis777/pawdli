// import 'dart:convert';
// import 'dart:io';

// class SlotItem {
//   final int slotId;
//   final String date;

//   SlotItem({
//     required this.slotId,
//     required this.date,
//   });

//   Map<String, dynamic> toJson() => {
//         "slot_id": slotId,
//         "date": date,
//       };
// }

// class RadioProgramModel {
//   final int userId;
//   final String programMode; // live / recorded
//   final String programName;
//   final String programDescription;
//   final String language;
//   final String programType; // Talk Show, Podcast, etc.
//   final String? recordedType;
//   final File? uploadFile;
//   final List<SlotItem> slots;

//   RadioProgramModel({
//     required this.userId,
//     required this.programMode,
//     required this.programName,
//     required this.programDescription,
//     required this.language,
//     required this.programType,
//     required this.recordedType,
//     required this.uploadFile,
//     required this.slots,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "user_id": userId,
//       "program_mode": programMode,
//       "program_name": programName,
//       "program_description": programDescription,
//       "language": language,
//       "program_type": programType,
//       "recorded_type": recordedType,
//       "slots": slots.map((e) => e.toJson()).toList(),
//     };
//   }

//   /// For multipart request
//   Map<String, String> toMultipartFields() {
//     return {
//       "user_id": userId.toString(),
//       "program_mode": programMode,
//       "program_name": programName,
//       "program_description": programDescription,
//       "language": language,
//       "program_type": programType,
//       if (recordedType != null) "recorded_type": recordedType!,
//       "slots": jsonEncode(slots.map((e) => e.toJson()).toList()),
//     };
//   }
// }

