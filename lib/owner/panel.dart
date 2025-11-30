import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/Model/Admin.dart';
import 'package:project/Statemangement/AdminP.dart';
import 'package:intl/intl.dart'; // For date formatting

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<AdminProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: bookingProvider.getAllBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              // Safe image handling
              final imageUrl =
                  (booking.imageurl != null && booking.imageurl!.isNotEmpty)
                  ? booking.imageurl!.first
                  : 'https://via.placeholder.com/100';

              // Format dates safely
              String formatDate(dynamic date) {
                if (date is DateTime) {
                  return DateFormat('yyyy-MM-dd').format(date);
                }
                if (date is String && date.isNotEmpty) {
                  return date;
                }
                return 'N/A';
              }

              final checkIn = formatDate(booking.checkIn);
              final checkOut = formatDate(booking.checkOut);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 120,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Booking Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.propertyName ?? 'Unknown Property',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.city ?? 'Unknown City',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.userEmail ?? 'Unknown Email',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Check-in: $checkIn',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      'Check-out: $checkOut',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                DropdownButton<String>(
                                  value:
                                      [
                                        'Pending',
                                        'Confirmed',
                                        'Cancelled',
                                      ].contains(booking.status)
                                      ? booking.status
                                      : 'Pending',
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                  items: ['Pending', 'Confirmed', 'Cancelled']
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      bookingProvider.updateBookingStatus(
                                        booking.id,
                                        newValue,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),

                            // Status Dropdown
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
