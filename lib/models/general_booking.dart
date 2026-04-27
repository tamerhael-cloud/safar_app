import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralBooking {
  final String id;
  final String type; // 'Flight', 'Hotel', 'Car'
  final String customerName;
  final String details; // e.g. "Dubai to London" or "Hilton Hotel 3 nights"
  final double price; // Selling price to customer
  final double? costPrice; // Cost from supplier
  final String? supplierName;
  final String status; // 'Pending', 'Confirmed', 'Cancelled'
  final DateTime date;

  GeneralBooking({
    required this.id,
    required this.type,
    required this.customerName,
    required this.details,
    required this.price,
    this.costPrice,
    this.supplierName,
    this.status = 'Pending',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'customerName': customerName,
      'details': details,
      'price': price,
      'costPrice': costPrice,
      'supplierName': supplierName,
      'status': status,
      'date': Timestamp.fromDate(date),
    };
  }

  factory GeneralBooking.fromMap(String id, Map<String, dynamic> map) {
    return GeneralBooking(
      id: id,
      type: map['type'] ?? 'Flight',
      customerName: map['customerName'] ?? '',
      details: map['details'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: map['costPrice']?.toDouble(),
      supplierName: map['supplierName'],
      status: map['status'] ?? 'Pending',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
