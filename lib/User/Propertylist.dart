// lib/screens/property_list_screen.dart
import 'package:flutter/material.dart';
import 'package:project/Statemangement/userp.dart';
import 'package:project/widget/propertyListview.dart';

import 'package:provider/provider.dart';

class PropertyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('All Properties')),
      body: PropertyListView(propertyStream: provider.getPropertiesStream()),
    );
  }
}
