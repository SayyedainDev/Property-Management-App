// lib/widgets/property_list_view.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/Model/OwnerModel.dart';
import 'package:project/Statemangement/userp.dart';
import 'package:project/User/PropertyDetail.dart';
import 'package:provider/provider.dart';

class PropertyListView extends StatefulWidget {
  final Stream<List<Ownermodel>> propertyStream;

  const PropertyListView({super.key, required this.propertyStream});

  @override
  State<PropertyListView> createState() => _PropertyListViewState();
}

class _PropertyListViewState extends State<PropertyListView> {
  Map<String, bool> _favorites = {};
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    final favProvider = Provider.of<PropertyProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    favProvider.getUserFavorites(userId).then((favList) {
      setState(() {
        _favorites = {for (var id in favList) id: true};
        _loadingFavorites = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context, listen: false);

    return StreamBuilder<List<Ownermodel>>(
      stream: widget.propertyStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final properties = snapshot.data ?? [];

        if (properties.isEmpty) {
          return const Center(child: Text('No properties found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            final userId = FirebaseAuth.instance.currentUser!.uid;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Propertydetail(
                      pid: property.id,
                      title: property.title,
                      description: property.description,
                      price: property.price,
                      city: property.city,
                      images: property.images,
                      features: property.features,
                    ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: property.images.isNotEmpty
                              ? Image.network(
                                  property.images[0],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                )
                              : Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image, size: 48),
                                ),
                        ),
                        // Favorite Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.white.withOpacity(0.9),
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              icon: Icon(
                                _favorites[property.id] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _favorites[property.id] == true
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              onPressed: () async {
                                final oldState =
                                    _favorites[property.id] ?? false;
                                setState(() {
                                  _favorites[property.id] = !oldState;
                                });

                                final favProvider = context
                                    .read<PropertyProvider>();
                                await favProvider.toggleFavourite(
                                  PropertyId: property.id,
                                  UserId: userId,
                                  currentState: oldState,
                                );

                                if (favProvider.errorMessage != null) {
                                  setState(() {
                                    _favorites[property.id] = oldState;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                property.city,
                                style: const TextStyle(color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'From £${property.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
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
    );
  }
}
