import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id; // Firestore document ID
  final String propertyId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;

  // Optional fields for admin display
  final String? propertyName;
  final String? userEmail;
  final List<String>? imageurl;
  final String? city;

  Booking({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.propertyName,
    this.userEmail,
    this.imageurl,
    this.city,
  });

  // Factory to create Booking from Firestore doc
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Booking(
      id: doc.id,
      propertyId: data['propertyId'] ?? '',
      userId: data['userId'] ?? '',
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: (data['checkOut'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }

  // Convert Booking to Firestore format (if needed)
  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'userId': userId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'status': status,
    };
  }

  // Copy with updates (useful for adding property/user info later)
  Booking copyWith({
    String? propertyName,
    String? userEmail,
    List<String>? imageurl,
    String? city,
  }) {
    return Booking(
      id: id,
      propertyId: propertyId,
      userId: userId,
      checkIn: checkIn,
      checkOut: checkOut,
      status: status,
      propertyName: propertyName ?? this.propertyName,
      userEmail: userEmail ?? this.userEmail,
      imageurl: imageurl,
      city: city,
    );
  }
}
