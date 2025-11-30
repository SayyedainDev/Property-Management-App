import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Model/BookingModel.dart';
import 'package:project/Model/BookingScreen.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BookingModel> _bookings = [];
  List<BookingModel> _bookDates = [];

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get bookDates => _bookDates;

  Future<void> fetchBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      _bookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  Future<void> createBooking({
    required String userId,
    required String propertyId,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required String status,
  }) async {
    try {
      await _firestore.collection('bookings').doc().set({
        'userId': userId,
        'propertyId': propertyId,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'status': status,
      });

      // Optional: refresh bookings for that user after creating
      await fetchBookings(userId);
    } catch (e) {
      print("Error creating booking: $e");
    }
  }

  Future<List<DateTime>> fetchUnavailableDatesByProperty(
    String propertyId,
  ) async {
    List<DateTime> bookedDays = [];
    try {
      final snapshot = await _firestore
          .collection("bookings")
          .where('propertyId', isEqualTo: propertyId)
          .get();

      _bookDates = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();

      // ✅ Loop through _bookDates instead of 'bookings'
      for (var booking in _bookDates) {
        DateTime start = booking.checkIn!;
        DateTime end = booking.checkOut!;

        for (
          DateTime date = start;
          !date.isAfter(end);
          date = date.add(const Duration(days: 1))
        ) {
          bookedDays.add(DateTime(date.year, date.month, date.day));
        }
      }
    } catch (e) {
      print("Error fetching bookings by property: $e");
    }
    return bookedDays;
  }

  Stream<List<BookingModelScreen>> streamUserBookings() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((bookingsSnapshot) async {
          List<BookingModelScreen> userBookings = [];

          for (var bookingDoc in bookingsSnapshot.docs) {
            final bookingData = bookingDoc.data();
            final propertyId = bookingData['propertyId'];
            print("propertyId ${propertyId}");
            // Fetch property details
            final propertyDoc = await _firestore
                .collection('properties')
                .doc(propertyId)
                .get();

            if (propertyDoc.exists) {
              final propertyData = propertyDoc.data()!;
              print(propertyData['images']);
              print(propertyData['images'].runtimeType);
              userBookings.add(
                BookingModelScreen.fromData(
                  propertyData: propertyData,
                  bookingData: bookingData,
                ),
              );
            }
          }

          return userBookings;
        });
  }
}
