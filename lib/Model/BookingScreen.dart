import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModelScreen {
  final String propertyName;
  final String propertyImage; // ✅ stays as String
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;

  BookingModelScreen({
    required this.propertyName,
    required this.propertyImage,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  factory BookingModelScreen.fromData({
    required Map<String, dynamic> propertyData,
    required Map<String, dynamic> bookingData,
  }) {
    String firstImage = "";

    final images = propertyData["images"];
    if (images is List && images.isNotEmpty) {
      firstImage = images.first.toString();
    } else if (images is String) {
      firstImage = images;
    }

    return BookingModelScreen(
      propertyName: propertyData["title"] ?? "",
      propertyImage: firstImage,
      checkIn: (bookingData["checkIn"] as Timestamp).toDate(),
      checkOut: (bookingData["checkOut"] as Timestamp).toDate(),
      status: bookingData["status"] ?? "",
    );
  }
}
