import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_account.dart';

enum UserRole { user, admin }

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() {
    _listenToUsers();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserRole? _role;
  String? _userName;
  String? _userId;
  final List<UserAccount> _registeredUsers = [];

  UserRole? get role => _role;
  String? get userName => _userName;
  String? get userId => _userId;
  bool get isAuthenticated => _role != null;
  List<UserAccount> get registeredUsers => List.unmodifiable(_registeredUsers);

  // Real-time listener on users collection (admin can see all registered users)
  void _listenToUsers() {
    _db.collection('users').snapshots().listen((snapshot) {
      _registeredUsers.clear();
      _registeredUsers.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return UserAccount(
          email: data['email'] ?? '',
          username: data['username'] ?? doc.id,
          password: data['password'] ?? '',
          phoneNumber: data['phoneNumber'],
          isGoogleUser: data['isGoogleUser'] ?? false,
          isAdmin: data['isAdmin'] ?? false,
        );
      }).toList());
      notifyListeners();
    }, onError: (e) {
      debugPrint('Firestore Error: $e');
    });
  }

  // Register using Firebase Auth (email/password) + write user to Firestore
  Future<bool> register(UserAccount account) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: account.email,
        password: account.password,
      );
      final uid = credential.user!.uid;
      await _db.collection('users').doc(uid).set({
        'email': account.email,
        'username': account.username,
        'password': account.password, // stored hashed ideally but this aligns with local model
        'phoneNumber': account.phoneNumber,
        'isGoogleUser': account.isGoogleUser,
        'isAdmin': account.isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mark the user as authenticated immediately after registration
      _userName = account.username;
      _userId = uid;
      _role = account.isAdmin ? UserRole.admin : UserRole.user;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Registration Error: $e');
      return false;
    }
  }

  // Login with Firebase Auth, then fetch role from Firestore
  Future<bool> login(String emailOrUsername, String password) async {
    try {
      // Try to find the email from the username in our Firestore users collection
      String email = emailOrUsername;
      if (!emailOrUsername.contains('@')) {
        // Look up email by username from loaded list
        final match = _registeredUsers.where((u) => u.username == emailOrUsername).toList();
        if (match.isNotEmpty) {
          email = match.first.email;
        } else {
          // Try fetching from Firestore directly
          final query = await _db.collection('users').where('username', isEqualTo: emailOrUsername).get();
          if (query.docs.isNotEmpty) {
            email = query.docs.first.data()['email'] ?? '';
          } else {
            debugPrint('Login Error: Username not found');
            return false; // User not found
          }
        }
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        _userName = data['username'] ?? emailOrUsername;
        _userId = uid;
        _role = (data['isAdmin'] ?? false) ? UserRole.admin : UserRole.user;
        notifyListeners();
        return true;
      }
      debugPrint('Login Error: User document not found in Firestore');
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<bool> updateUserCredentials(String currentUsername, String newUsername, String newPassword) async {
    try {
      // Find user in Firestore
      final query = await _db.collection('users').where('username', isEqualTo: currentUsername).get();
      if (query.docs.isEmpty) return false;
      
      final doc = query.docs.first;
      await doc.reference.update({
        'username': newUsername,
        'password': newPassword,
      });

      // Update current session if it was the logged in user
      if (_userName == currentUsername) {
        _userName = newUsername;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Update Credentials Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userName = null;
    _userId = null;
    _role = null;
    notifyListeners();
  }

  // Ensure default admin account exists in Firestore
  Future<void> ensureAdminExists() async {
    const adminEmail = 'admin@safar.com';
    const adminPassword = 'admin123';
    try {
      final query = await _db.collection('users').where('isAdmin', isEqualTo: true).get();
      if (query.docs.isEmpty) {
        // Create admin account in Firebase Auth
        try {
          final credential = await _auth.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          await _db.collection('users').doc(credential.user!.uid).set({
            'email': adminEmail,
            'username': 'admin',
            'password': adminPassword,
            'isAdmin': true,
            'isGoogleUser': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          // Admin might already exist in Auth
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
