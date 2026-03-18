class OrderCreationModel {
  String? message;
  int? bookingId;
  String? razorpayOrderId;
  SlotDetails? slotDetails;

  OrderCreationModel(
      {this.message, this.bookingId, this.razorpayOrderId, this.slotDetails});

  OrderCreationModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    bookingId = json['booking_id'];
    razorpayOrderId = json['razorpay_order_id'];
    slotDetails = json['slot_details'] != null
        ? new SlotDetails.fromJson(json['slot_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['booking_id'] = this.bookingId;
    data['razorpay_order_id'] = this.razorpayOrderId;
    if (this.slotDetails != null) {
      data['slot_details'] = this.slotDetails!.toJson();
    }
    return data;
  }
}

class SlotDetails {
  int? slotId;
  String? startTime;
  String? endTime;
  String? station;

  SlotDetails({this.slotId, this.startTime, this.endTime, this.station});

  SlotDetails.fromJson(Map<String, dynamic> json) {
    slotId = json['slot_id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    station = json['station'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slot_id'] = this.slotId;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['station'] = this.station;
    return data;
  }
}
