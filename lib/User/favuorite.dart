import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Statemangement/userp.dart';
import 'package:project/widget/propertyListview.dart';

import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: PropertyListView(
        propertyStream: provider.getFavoritePropertiesStreams(userId),
      ),
    );
  }
}
