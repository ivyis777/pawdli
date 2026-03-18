class SubscriptionModel {
  final int userId;
  final String username;
  final List<ProgramData> data;

  SubscriptionModel({
    required this.userId,
    required this.username,
    required this.data,
  });

  // Factory method to create an instance from JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      userId: json['user_id'],
      username: json['username'],
      data: List<ProgramData>.from(json['data'].map((x) => ProgramData.fromJson(x))),
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class ProgramData {
  final String programName;
  final String programDescription;
  final String date;
  final String time;
  final bool isHost;
  final String host;
  final double amount;
  final String? programType;
  final int? bookingId;
    bool isRestart; 

  ProgramData({
    required this.programName,
    required this.programDescription,
    required this.date,
    required this.time,
    required this.isHost,
    required this.host,
    required this.amount,
    this.programType,
    this.bookingId,
     this.isRestart = false, 
  });

  factory ProgramData.fromJson(Map<String, dynamic> json) {
    return ProgramData(
      programName: json['program_name'] ?? '',
      programDescription: json['program_description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      isHost: _parseIsHost(json['is_host']),
      host: json['host'] ?? '',
      amount: _parseAmount(json['amount']),
      programType: json['program_type'],
      bookingId: json['booking_id'] != null
          ? int.tryParse(json['booking_id'].toString())
          : null,
    );
  }

  static bool _parseIsHost(dynamic isHost) {
    if (isHost is bool) {
      return isHost;
    }
    return isHost == 'true';
  }

  static double _parseAmount(dynamic amount) {
    if (amount is double) {
      return amount;
    }
    return double.tryParse(amount.toString()) ?? 0.0;
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'program_name': programName,
      'program_description': programDescription,
      'date': date,
      'time': time,
      'is_host': isHost.toString(),
      'host': host,
      'amount': amount,
      'program_type': programType,
      'booking_id': bookingId,
    };
  }

  // Override the toString() method for better debugging output
  @override
  String toString() {
    return 'ProgramData(programName: $programName, programDescription: $programDescription, date: $date, time: $time, isHost: $isHost, host: $host, amount: $amount, programType: $programType, bookingId: $bookingId)';
  }
}
