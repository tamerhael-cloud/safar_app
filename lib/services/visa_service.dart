import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visa_application.dart';
import '../models/visa_pricing.dart';

class VisaService extends ChangeNotifier {
  static final VisaService _instance = VisaService._internal();
  factory VisaService() => _instance;
  VisaService._internal() {
    _listenToApplications();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<VisaApplication> _applications = [];
  List<CountryVisaData> _pricingData = List.from(visaPricingData);
  bool _hasNewNotification = false;

  List<VisaApplication> get applications => List.unmodifiable(_applications);
  List<CountryVisaData> get pricingData => _pricingData;
  bool get hasNewNotification => _hasNewNotification;

  void clearNotification() {
    _hasNewNotification = false;
    notifyListeners();
  }

  // Real-time listener to Firestore
  void _listenToApplications() {
    _db
        .collection('visa_applications')
        // .orderBy('submissionDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      final int previousCount = _applications.length;
      _applications.clear();
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          _applications.add(VisaApplication.fromMap(data));
        } catch (e) {
          debugPrint('Error parsing visa application ${doc.id}: $e');
        }
      }

      if (_applications.length > previousCount) {
        _hasNewNotification = true;
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('Visa Firestore Error: $e');
    });
  }

  Future<void> refreshApplications() async {
    try {
      final snapshot = await _db.collection('visa_applications').get();
      _applications.clear();
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          _applications.add(VisaApplication.fromMap(data));
        } catch (e) {
          debugPrint('Error parsing visa application ${doc.id}: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing visas: $e');
    }
  }

  Future<void> submitApplication(VisaApplication application) async {
    final data = application.toMap();
    data['submissionDate'] = FieldValue.serverTimestamp();
    await _db.collection('visa_applications').add(data);
    // _listenToApplications will auto-refresh
  }

  Future<void> updateApplicationStatus(String id, String newStatus,
      {String? visaPath, String? visaName}) async {
    final updates = <String, dynamic>{'status': newStatus};
    if (visaPath != null) {
      updates['approvedVisaFilePath'] = visaPath;
      updates['approvedVisaFileName'] = visaName;
    }
    await _db.collection('visa_applications').doc(id).update(updates);
  }

  void notifyListenersManual() {
    notifyListeners();
  }
}
