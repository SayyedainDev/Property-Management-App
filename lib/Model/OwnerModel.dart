import 'package:hive/hive.dart';

part 'OwnerModel.g.dart'; // 👈 add this line

@HiveType(typeId: 0)
class Ownermodel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final List<String> images;

  @HiveField(6)
  final List<String> features;

  Ownermodel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.images,
    required this.features,
  });

  factory Ownermodel.fromMap(String id, Map<String, dynamic> map) {
    return Ownermodel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      city: map['city'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      features: List<String>.from(map['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'city': city,
      'images': images,
      'features': features,
    };
  }
}
