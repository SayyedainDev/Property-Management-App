import "package:carousel_slider/carousel_slider.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

import "package:project/Statemangement/BookingP.dart";
import "package:provider/provider.dart";
import "package:syncfusion_flutter_datepicker/datepicker.dart";

class Propertydetail extends StatefulWidget {
  String title = "";
  String description = "";
  double price = 0;
  String city = "";
  List<String> images = [];
  List<String> features = [];
  String pid = "";

  Propertydetail({
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.images,
    required this.features,
    required this.pid,
    Key? key,
  }) : super(key: key);
  @override
  _propertydetail createState() => _propertydetail();
}

class _propertydetail extends State<Propertydetail> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  List<DateTime> bookedDates = [];

  // fetch date from firebase
  @override
  void initState() {
    super.initState();
    _loadUnavailableDates();
  }

  Future<void> _loadUnavailableDates() async {
    final bookedDays = await Provider.of<BookingProvider>(
      context,
      listen: false,
    ).fetchUnavailableDatesByProperty(widget.pid);

    setState(() {
      bookedDates = bookedDays
          .map((d) => DateTime(d.year, d.month, d.day))
          .toList();
    });

    // 🔍 Debug print to check fetched unavailable dates
    print("DEBUG: Loaded bookedDates (${bookedDates.length}):");
    for (var date in bookedDates) {
      print("  ${date.toIso8601String()}");
    }
  }

  // Utility method to format a date
  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  // Handles setting check-in or check-out safely
  void _setDate(DateTime date, bool isCheckIn) {
    setState(() {
      if (isCheckIn) {
        checkInDate = date;
        // If new check-in is after or same as check-out, reset check-out
        if (checkOutDate != null && !checkOutDate!.isAfter(checkInDate!)) {
          checkOutDate = null;
        }
      } else {
        checkOutDate = date;
      }
    });
  }

  void _selectDate(bool isCheckIn) async {
    // ✅ Ensure bookedDates is loaded before opening the picker
    if (bookedDates.isEmpty) {
      await _loadUnavailableDates();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            height: 350,
            width: 300,
            child: SfDateRangePicker(
              monthViewSettings: DateRangePickerMonthViewSettings(
                blackoutDates: bookedDates,
              ),
              enablePastDates: false, // ✅ Prevent past date selection
              onSelectionChanged: (args) {
                if (args.value is DateTime &&
                    !bookedDates.contains(
                      DateTime(
                        args.value.year,
                        args.value.month,
                        args.value.day,
                      ),
                    )) {
                  _setDate(args.value, isCheckIn);
                  Navigator.pop(context);
                }
              },
              selectionMode: DateRangePickerSelectionMode.single,
              showNavigationArrow: true,
              minDate: isCheckIn
                  ? DateTime.now()
                  : (checkInDate != null
                        ? checkInDate!.add(Duration(days: 1))
                        : DateTime.now().add(Duration(days: 1))),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateButton(String title, DateTime? date, bool isCheckIn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade400),
        ),
        elevation: 0,
      ),
      onPressed: () => _selectDate(isCheckIn),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null ? _formatDate(date) : title,
            style: const TextStyle(fontSize: 16),
          ),
          const Icon(Icons.calendar_today, color: Colors.grey),
        ],
      ),
    );
  }

  Widget build(context) {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(title: Text("Details")),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),
            // Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) {
                      setState(() {});
                    },
                  ),
                  items: widget.images.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
                // Indicator dots
              ],
            ),

            // Title, Price, City
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${widget.price.toStringAsFixed(2)} / night",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color.fromARGB(255, 0, 0, 0),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.city,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.features
                    .map(
                      (feature) => Chip(
                        label: Text(feature),
                        backgroundColor: Colors.teal.shade50,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Date pickers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Dates",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [

                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  _buildDateButton("Check In", checkInDate, true),
                  const SizedBox(height: 15),
                  _buildDateButton("Check Out", checkOutDate, false),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Book button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (checkInDate != null && checkOutDate != null) {
                      bookingProvider.createBooking(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        propertyId: widget.pid,
                        checkIn: checkInDate,
                        checkOut: checkOutDate,
                        status: "Pending",
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please Enter Check In and Out Date"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: GestureDetector(
                    child: const Text(
                      "Book Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
