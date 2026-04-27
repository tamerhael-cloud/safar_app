import 'package:cloud_firestore/cloud_firestore.dart';

class VisaApplication {
  final String id;
  final String fullName;
  final String motherName;
  final String nationality;
  final String targetCountry;
  final String visaType;
  final double price;
  final String visitedCountries;
  final String? passportFileName;
  final String? passportFilePath;
  final DateTime submissionDate;
  String status;
  
  // New fields for the approved visa document from Admin
  String? approvedVisaFileName;
  String? approvedVisaFilePath;
  String? paymentMethod;
  
  // Payment Receipt
  String? paymentReceiptFileName;
  String? paymentReceiptFilePath;
  
  // User Tracking
  String? submittedBy;

  VisaApplication({
    required this.id,
    required this.fullName,
    required this.motherName,
    required this.nationality,
    required this.targetCountry,
    required this.visaType,
    required this.price,
    required this.visitedCountries,
    this.passportFileName,
    this.passportFilePath,
    required this.submissionDate,
    this.status = 'تحت المراجعة',
    this.approvedVisaFileName,
    this.approvedVisaFilePath,
    this.paymentMethod,
    this.paymentReceiptFileName,
    this.paymentReceiptFilePath,
    this.submittedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'motherName': motherName,
      'nationality': nationality,
      'targetCountry': targetCountry,
      'visaType': visaType,
      'price': price,
      'visitedCountries': visitedCountries,
      'passportFileName': passportFileName,
      'passportFilePath': passportFilePath,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status,
      'approvedVisaFileName': approvedVisaFileName,
      'approvedVisaFilePath': approvedVisaFilePath,
      'paymentMethod': paymentMethod,
      'paymentReceiptFileName': paymentReceiptFileName,
      'paymentReceiptFilePath': paymentReceiptFilePath,
      'submittedBy': submittedBy,
    };
  }

  factory VisaApplication.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    if (map['submissionDate'] is Timestamp) {
      parsedDate = (map['submissionDate'] as Timestamp).toDate();
    } else if (map['submissionDate'] is String) {
      parsedDate = DateTime.parse(map['submissionDate']);
    } else {
      parsedDate = DateTime.now();
    }

    return VisaApplication(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      motherName: map['motherName'] ?? '',
      nationality: map['nationality'] ?? '',
      targetCountry: map['targetCountry'] ?? '',
      visaType: map['visaType'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      visitedCountries: map['visitedCountries'] ?? '',
      passportFileName: map['passportFileName'],
      passportFilePath: map['passportFilePath'],
      submissionDate: parsedDate,
      status: map['status'] ?? 'تحت المراجعة',
      approvedVisaFileName: map['approvedVisaFileName'],
      approvedVisaFilePath: map['approvedVisaFilePath'],
      paymentMethod: map['paymentMethod'],
      paymentReceiptFileName: map['paymentReceiptFileName'],
      paymentReceiptFilePath: map['paymentReceiptFilePath'],
      submittedBy: map['submittedBy'],
    );
  }
}
