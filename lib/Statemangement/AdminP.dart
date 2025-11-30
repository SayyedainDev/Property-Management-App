import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/Model/Admin.dart';
// Adjust path as per your project

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all bookings with property & user info for Admin
  Stream<List<Booking>> getAllBookingsStream() async* {
    await for (final bookingSnapshot
        in _firestore.collection('bookings').snapshots()) {
      List<Booking> bookingsList = [];

      for (var doc in bookingSnapshot.docs) {
        try {
          final booking = Booking.fromFirestore(doc);

          // Fetch property and user in parallel
          final futures = await Future.wait([
            _firestore.collection('properties').doc(booking.propertyId).get(),
            _firestore.collection('users').doc(booking.userId).get(),
          ]);

          final propertyDoc = futures[0];
          final userDoc = futures[1];

          // Skip if property or user does not exist
          if (!propertyDoc.exists || !userDoc.exists) continue;

          final propertyData = propertyDoc.data();
          final userData = userDoc.data();

          // Safe parsing
          final propertyName = propertyData?['title'] ?? 'Unknown Property';
          final propertyImages = propertyData?['images'] != null
              ? List<String>.from(propertyData!['images'])
              : <String>[];
          final propertyCity = propertyData?['city'] ?? 'Unknown City';
          final username = userData?['user_name'] ?? 'Unknown User';

          final enrichedBooking = booking.copyWith(
            propertyName: propertyName,
            userEmail: username,
            city: propertyCity,
            imageurl: propertyImages, // ✅ list, not single string
          );

          bookingsList.add(enrichedBooking);
        } catch (e) {
          debugPrint("Error enriching booking: $e");
        }
      }

      yield bookingsList;
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint("Error updating booking status: $e");
    }
  }
}
