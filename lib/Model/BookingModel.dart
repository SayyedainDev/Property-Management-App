import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status; // pending, confirmed, cancelled

  BookingModel({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.checkIn,
    required this.checkOut,
    this.status = "pending",
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingModel(
      id: documentId,
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      checkIn: (map['checkIn'] as Timestamp).toDate(),
      checkOut: (map['checkOut'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'propertyId': propertyId,
      'checkIn': checkIn!.toIso8601String(),
      'checkOut': checkOut!.toIso8601String(),
      'status': status,
    };
  }
}
