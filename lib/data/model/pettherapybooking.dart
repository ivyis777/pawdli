
class PetTherapyBookingResponse {
  final String message;
  final String razorpayOrderId;
  final List<BookedSlot> bookedSlots;
  final dynamic unavailableSlots; // can be null or a list
  final String status;

  PetTherapyBookingResponse({
    required this.message,
    required this.razorpayOrderId,
    required this.bookedSlots,
    required this.unavailableSlots,
    required this.status,
  });

  factory PetTherapyBookingResponse.fromJson(Map<String, dynamic> json) {
    return PetTherapyBookingResponse(
      message: json['message'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      bookedSlots: (json['booked_slots'] as List<dynamic>? ?? [])
          .map((slot) => BookedSlot.fromJson(slot))
          .toList(),
      unavailableSlots: json['unavailable_slots'],
      status: json['status'] ?? '',
    );
  }
}

class BookedSlot {
  final int slotId;
  final String startTime;
  final String endTime;
  final int bookingId;
  final String date;

  BookedSlot({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.bookingId,
    required this.date,
  });

  factory BookedSlot.fromJson(Map<String, dynamic> json) {
    return BookedSlot(
      slotId: json['slot_id'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      bookingId: json['booking_id'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}
