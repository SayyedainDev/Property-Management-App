class PropertyModelU {
  final String id;
  final String title;
  final String city;
  final double price;
  final String description;
  final String images;
  final List<DateTime> bookedDates;
  final bool isBookmarked;

  PropertyModelU({
    required this.id,
    required this.title,
    required this.city,
    required this.price,
    required this.description,
    required this.images,
    required this.bookedDates,
    this.isBookmarked = false,
  });

  factory PropertyModelU.fromMap(Map<String, dynamic> map, String documentId) {
    return PropertyModelU(
      id: documentId,
      title: map['title'] ?? '',
      city: map['city'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      images: (map['images'] ?? []),
      bookedDates: (map['bookedDates'] ?? [])
          .map<DateTime>((date) => DateTime.parse(date))
          .toList(),
      isBookmarked: map['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'city': city,
      'price': price,
      'description': description,
      'images': images,
      'bookedDates': bookedDates.map((date) => date.toIso8601String()).toList(),
      'isBookmarked': isBookmarked,
    };
  }
}
