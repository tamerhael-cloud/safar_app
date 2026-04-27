import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/general_booking.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal() {
    _listenToBookings();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<GeneralBooking> _bookings = [];

  List<GeneralBooking> get bookings => List.unmodifiable(_bookings);

  void _listenToBookings() {
    _db.collection('bookings').orderBy('date', descending: true).snapshots().listen((snapshot) {
      _bookings.clear();
      for (var doc in snapshot.docs) {
        _bookings.add(GeneralBooking.fromMap(doc.id, doc.data()));
      }
      notifyListeners();
    });
  }

  Future<void> createBooking(GeneralBooking booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  Future<void> updateBooking(String id, {double? costPrice, String? supplierName, String? status}) async {
    final Map<String, dynamic> updates = {};
    if (costPrice != null) updates['costPrice'] = costPrice;
    if (supplierName != null) updates['supplierName'] = supplierName;
    if (status != null) updates['status'] = status;
    
    await _db.collection('bookings').doc(id).update(updates);
  }
}
