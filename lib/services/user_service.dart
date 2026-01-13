import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's data from Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      
      if (!doc.exists) {
        // Create a default user document if it doesn't exist
        final newUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          name: currentUser.displayName ?? 'User',
          role: 'preacher', // Default role
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(currentUser.uid).set(newUser.toMap());
        return newUser;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Stream of current user data
  Stream<UserModel?> getCurrentUserStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Create user profile (usually called after registration)
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String role = 'preacher',
    String? phoneNumber,
  }) async {
    try {
      final user = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Get all users with a specific role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }
}
