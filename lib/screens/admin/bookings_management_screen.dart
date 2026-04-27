import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/booking_service.dart';
import '../../services/suppliers_service.dart';
import '../../models/general_booking.dart';

class BookingsManagementScreen extends StatelessWidget {
  const BookingsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة حجوزات الطيران والفنادق', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: bookingService,
        builder: (context, _) {
          final bookings = bookingService.bookings;

          if (bookings.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(_getIcon(booking.type), color: AppTheme.safarBlue),
                  title: Text('${booking.type}: ${booking.details}'),
                  subtitle: Text('العميل: ${booking.customerName} | ${booking.status}'),
                  trailing: Text('\$${booking.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => _showBookingAction(context, booking),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type == 'Flight') return Icons.flight;
    if (type == 'Hotel') return Icons.hotel;
    return Icons.directions_car;
  }

  void _showBookingAction(BuildContext context, GeneralBooking b) {
    final costCtrl = TextEditingController(text: b.costPrice?.toString() ?? '');
    String? selectedSupplier = b.supplierName;
    final suppliersService = SuppliersService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إدارة حجز ${b.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: suppliersService.suppliers.any((s) => s.name == selectedSupplier) ? selectedSupplier : null,
                decoration: const InputDecoration(labelText: 'اختر المورد', border: OutlineInputBorder()),
                items: suppliersService.suppliers
                    .where((s) => s.category == b.type)
                    .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => selectedSupplier = v,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'سعر التكلفة', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        BookingService().updateBooking(
                          b.id, 
                          costPrice: double.tryParse(costCtrl.text),
                          supplierName: selectedSupplier,
                          status: 'Confirmed'
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('تأكيد الحجز'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        BookingService().updateBooking(b.id, status: 'Cancelled');
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('إلغاء'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
