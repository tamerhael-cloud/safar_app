import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Supplier {
  final String id;
  final String name;
  final String category; // 'Visa', 'Flight', 'Hotel', 'Car'
  final String phoneNumber;
  final String email;

  Supplier({
    required this.id,
    required this.name,
    required this.category,
    this.phoneNumber = '',
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory Supplier.fromMap(String id, Map<String, dynamic> map) {
    return Supplier(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'Visa',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

class SuppliersService extends ChangeNotifier {
  static final SuppliersService _instance = SuppliersService._internal();
  factory SuppliersService() => _instance;
  SuppliersService._internal() {
    _listenToSuppliers();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Supplier> _suppliers = [];

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  void _listenToSuppliers() {
    _db.collection('suppliers').snapshots().listen((snapshot) {
      _suppliers.clear();
      for (var doc in snapshot.docs) {
        _suppliers.add(Supplier.fromMap(doc.id, doc.data()));
      }
      notifyListeners();
    });
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _db.collection('suppliers').add(supplier.toMap());
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _db.collection('suppliers').doc(supplier.id).update(supplier.toMap());
  }

  Future<void> deleteSupplier(String id) async {
    await _db.collection('suppliers').doc(id).delete();
  }
}
