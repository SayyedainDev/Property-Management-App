import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:project/Model/OwnerModel.dart";

class Ownerp with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Uint8List> _selectedImage = []; // ✅ start empty list
  List<String> _uploadedImageUrl = []; // ✅ start empty list
  List<Ownermodel> _properties = [];

  List<Ownermodel> get properties => _properties;
  List<Uint8List> get selectedImage => _selectedImage;

  set selectedImage(List<Uint8List> value) {
    _selectedImage = value;
    notifyListeners();
  }

  void setImage(List<Uint8List> images) {
    _selectedImage = images;
    notifyListeners();
  }

  void removeImage() {
    _selectedImage.clear();
    notifyListeners();
  }

  /// Upload a single image to Supabase and return its public URL
  Future<String> uploadImageToSupabase(Uint8List imageBytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final response = await _supabase.storage
        .from('images') // <-- bucket name
        .uploadBinary(fileName, imageBytes);

    if (response.isEmpty) {
      throw Exception('Image upload failed');
    }

    return _supabase.storage.from('images').getPublicUrl(fileName);
  }

  /// Submit property and store Supabase URLs in Firebase
  Future<void> submitProperty({
    required String title,
    required String description,
    required double price,
    required String city,
    required List<String> features,
  }) async {
    if (_selectedImage.isEmpty) {
      throw Exception("No images selected");
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    // ✅ Ensure the list is empty before uploading
    _uploadedImageUrl.clear();
    print("${_selectedImage.length}");
    // Upload each image
    for (var image in _selectedImage) {
      final url = await uploadImageToSupabase(image);
      print("url${url}");
      _uploadedImageUrl.add(url);
    }

    final property = Ownermodel(
      id: '',
      title: title,
      description: description,
      price: price,
      city: city,
      images: _uploadedImageUrl,
      features: features,
    );

    await FirebaseFirestore.instance.collection('properties').add({
      ...property.toMap(),
      'ownerId': currentUser.uid,
    });

    // ✅ Reset after submit
    _selectedImage.clear();
    _uploadedImageUrl.clear();

    notifyListeners();
  }

  /// Fetch all properties for current user
  Future<void> fetchProperties() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('properties')
        .where('ownerId', isEqualTo: currentUser.uid)
        .get();

    _properties = snapshot.docs.map((doc) {
      return Ownermodel.fromMap(doc.id, doc.data());
    }).toList();

    notifyListeners();
  }

  // / Live stream of properties for current user
  Stream<List<Ownermodel>> getPropertiesStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    return FirebaseFirestore.instance
        .collection('properties')
        .where('ownerId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          _properties = snapshot.docs.map((doc) {
            return Ownermodel.fromMap(doc.id, doc.data());
          }).toList();

          notifyListeners();
          return _properties;
        });
  }

  Future<void> deleteProperty(String id) async {
    await _firestore.collection('properties').doc(id).delete();
  }

  Future<void> updateProperty(String id, Map<String, dynamic> data) async {
    await _firestore.collection('properties').doc(id).update(data);
  }
}
