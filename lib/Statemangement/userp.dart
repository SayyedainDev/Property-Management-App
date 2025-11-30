import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Model/OwnerModel.dart';
import 'package:project/Model/userModel.dart';

class PropertyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List<Ownermodel> _properties = [];
  List<Ownermodel> get properties => _properties;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Stream all properties and listen for real-time updates
  Stream<List<Ownermodel>> getPropertiesStream() {
    print("getPropertiesStream called");
    return FirebaseFirestore.instance.collection('properties').snapshots().map((
      snapshot,
    ) {
      try {
        print("Snapshot received with ${snapshot.docs.length} docs");
        _properties = snapshot.docs.map((doc) {
          return Ownermodel.fromMap(doc.id, doc.data());
        }).toList();
      } catch (e, st) {
        print("Error mapping properties: $e");
        print(st);
      }

      notifyListeners(); // update provider listeners
      return _properties;
    });
  }

  Stream<List<PropertyModelU>> streamUserBookmarkedProperties() {
    print("streamUserBookmarkedProperties called for userId: $userId");
    return _firestore
        .collection('properties')
        .where('bookmarkedBy', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          print(
            "Bookmarked snapshot received with ${snapshot.docs.length} docs",
          );
          try {
            return snapshot.docs
                .map((doc) => PropertyModelU.fromMap(doc.data(), doc.id))
                .toList();
          } catch (e, st) {
            print("Error mapping bookmarked properties: $e");
            print(st);
            return [];
          }
        });
  }

  Future<void> toggleFavourite({
    required String PropertyId,
    required String UserId,
    required bool currentState,
  }) async {
    print(
      "toggleFavourite called for PropertyId: $PropertyId, currentState: $currentState",
    );
    try {
      final UserDoc = await _firestore.collection("users").doc(userId);
      if (_isBusy) {
        print("toggleFavourite skipped because _isBusy is true");
        return;
      }
      _isBusy = true;
      _errorMessage = null;
      notifyListeners();

      if (!currentState) {
        await UserDoc.update({
          'favourite': FieldValue.arrayUnion([PropertyId]),
        });
        print("Added to favourites");
      } else {
        await UserDoc.update({
          'favourite': FieldValue.arrayRemove([PropertyId]),
        });
        print("Removed from favourites");
      }
    } on FirebaseException catch (e) {
      _errorMessage = e.message ?? 'Something went wrong with Firestore';
      print("FirebaseException in toggleFavourite: $_errorMessage");
    } catch (e, st) {
      _errorMessage = 'Unexpected error: $e';
      print("Error in toggleFavourite: $e");
      print(st);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<List<String>> getUserFavorites(String userId) async {
    print("getUserFavorites called for userId: $userId");
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final favs = List<String>.from(doc['favourite'] ?? []);
        print("Favorites fetched: $favs");
        return favs;
      } else {
        print("User doc does not exist");
      }
    } catch (e, st) {
      print("Error in getUserFavorites: $e");
      print(st);
    }
    return [];
  }

  Future<bool> isFavorite({
    required String userId,
    required String propertyId,
  }) async {
    print("isFavorite called for userId: $userId, propertyId: $propertyId");
    try {
      final snap = await _firestore.collection('users').doc(userId).get();
      if (!snap.exists) {
        print("User doc does not exist");
        return false;
      }

      final favs =
          (snap.data()?['favourite'] as List?)?.cast<String>() ??
          const <String>[];
      final result = favs.contains(propertyId);
      print("isFavorite result: $result");
      return result;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} ${e.message}');
      return false;
    } catch (e, st) {
      debugPrint('Unexpected error: $e');
      print(st);
      return false;
    }
  }

  Stream<List<String>> favoritesStream(String userId) {
    print("favoritesStream called for userId: $userId");
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final favs = List<String>.from(doc['favourite'] ?? []);
        print("favoritesStream update: $favs");
        return favs;
      }
      return [];
    });
  }

  Stream<List<Ownermodel>> getFavoritePropertiesStreams(String userId) {
    print("getFavoritePropertiesStreams called for userId: $userId");
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((
      doc,
    ) async {
      try {
        if (!doc.exists || !(doc.data()?.containsKey('favourite') ?? false)) {
          print("User doc missing or no favourites");
          return [];
        }
        final favoriteIds = List<String>.from(doc['favourite']);
        if (favoriteIds.isEmpty) {
          print("No favourite IDs");
          return [];
        }

        final snapshot = await _firestore
            .collection('properties')
            .where(FieldPath.documentId, whereIn: favoriteIds)
            .get();

        final properties = snapshot.docs
            .map((d) => Ownermodel.fromMap(d.id, d.data()))
            .toList();
        print("Fetched ${properties.length} favorite properties");
        return properties;
      } catch (e, st) {
        print("Error in getFavoritePropertiesStreams: $e");
        print(st);
        return [];
      }
    });
  }
}
