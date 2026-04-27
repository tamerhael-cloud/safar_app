import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/visa_application.dart';
import '../models/visa_pricing.dart';

class VisaService extends ChangeNotifier {
  static final VisaService _instance = VisaService._internal();
  factory VisaService() => _instance;
  VisaService._internal() {
    _listenToApplications();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  Future<String?> _uploadFile(String localPath, String folder) async {
    if (localPath.isEmpty) return null;
    try {
      File file = File(localPath);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + localPath.split('/').last;
      Reference ref = _storage.ref().child(folder).child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload Error ($folder): $e');
      return null;
    }
  }

  Future<void> submitApplication(VisaApplication application) async {
    // 1. Upload Passport
    String? passportUrl;
    if (application.passportFilePath != null) {
      passportUrl = await _uploadFile(application.passportFilePath!, 'passports');
    }

    // 2. Upload Payment Receipt
    String? receiptUrl;
    if (application.paymentReceiptFilePath != null) {
      receiptUrl = await _uploadFile(application.paymentReceiptFilePath!, 'receipts');
    }

    final data = application.toMap();
    data['submissionDate'] = FieldValue.serverTimestamp();
    
    // Update with URLs instead of local paths
    if (passportUrl != null) data['passportFilePath'] = passportUrl;
    if (receiptUrl != null) data['paymentReceiptFilePath'] = receiptUrl;

    await _db.collection('visa_applications').add(data);
  }

  Future<void> updateApplicationStatus(String id, String newStatus,
      {String? visaPath, String? visaName, double? costPrice, String? supplierName}) async {
    final updates = <String, dynamic>{'status': newStatus};
    
    if (costPrice != null) updates['costPrice'] = costPrice;
    if (supplierName != null) updates['supplierName'] = supplierName;

    if (visaPath != null) {
      // Upload the approved visa document if provided
      String? visaUrl = await _uploadFile(visaPath, 'approved_visas');
      if (visaUrl != null) {
        updates['approvedVisaFilePath'] = visaUrl;
        updates['approvedVisaFileName'] = visaName;
      }
    }
    await _db.collection('visa_applications').doc(id).update(updates);
  }

  void notifyListenersManual() {
    notifyListeners();
  }
}
