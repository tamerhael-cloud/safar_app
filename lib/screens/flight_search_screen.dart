import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/flight_data.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  // Common state
  int _tripType = 0; // 0: One Way, 1: Round Trip, 2: Multi-City
  
  // Single/Round Trip state
  Location _from = mockLocations[0];
  Location _to = mockLocations[2];
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _returnDate;

  // Multi-City state
  List<FlightSegment> _segments = [
    FlightSegment(from: mockLocations[0], to: mockLocations[2], date: DateTime.now().add(const Duration(days: 7))),
    FlightSegment(from: mockLocations[2], to: mockLocations[3], date: DateTime.now().add(const Duration(days: 14))),
  ];

  void _selectLocation(bool isFrom, {int? segmentIndex}) async {
    final Location? selected = await showModalBottomSheet<Location>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerModal(),
    );

    if (selected != null) {
      setState(() {
        if (_tripType == 2 && segmentIndex != null) {
          if (isFrom) {
            _segments[segmentIndex].from = selected;
          } else {
            _segments[segmentIndex].to = selected;
          }
        } else {
          if (isFrom) {
            _from = selected;
          } else {
            _to = selected;
          }
        }
      });
    }
  }

  void _selectDate(bool isDeparture, {int? segmentIndex}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (_tripType == 2 && segmentIndex != null) {
          _segments[segmentIndex].date = picked;
        } else {
          if (isDeparture) {
            _departureDate = picked;
          } else {
            _returnDate = picked;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Search Flights', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildTripTypeToggle(),
                  const SizedBox(height: 24),
                  if (_tripType == 2) _buildMultiCityList() else _buildStandardPickers(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FlightResultsScreen()));
                    },
                    child: const Text('Search Flights'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem('One Way', 0),
          _buildToggleItem('Round Trip', 1),
          _buildToggleItem('Multi-City', 2),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, int index) {
    bool isSelected = _tripType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tripType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.safarBlue : AppTheme.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardPickers() {
    return Column(
      children: [
        _buildLocationRow(),
        const Divider(height: 32),
        _buildDateRow(),
        const Divider(height: 32),
        _buildSearchField(Icons.person_outline, 'Passengers', '1 Adult, Economy'),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Column(
          children: [
            _buildInteractivePicker('From', _from, true),
            const Divider(height: 32),
            _buildInteractivePicker('To', _to, false),
          ],
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: () => setState(() {
              final temp = _from;
              _from = _to;
              _to = temp;
            }),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: const Icon(Icons.swap_vert, color: AppTheme.safarBlue, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractivePicker(String label, Location loc, bool isFrom) {
    return InkWell(
      onTap: () => _selectLocation(isFrom),
      child: Row(
        children: [
          Icon(isFrom ? Icons.flight_takeoff : Icons.flight_land, color: AppTheme.safarBlue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(loc.city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              Text('${loc.code} - ${loc.airport}', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(true),
            child: _buildSearchField(Icons.calendar_today, 'Departure', '${_departureDate.day} ${_monthName(_departureDate.month)}'),
          ),
        ),
        if (_tripType == 1) ...[
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(false),
              child: _buildSearchField(Icons.calendar_today, 'Return', _returnDate == null ? 'Select Date' : '${_returnDate!.day} ${_monthName(_returnDate!.month)}'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMultiCityList() {
    return Column(
      children: [
        ..._segments.asMap().entries.map((entry) {
          int idx = entry.key;
          FlightSegment seg = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flight ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
              const SizedBox(height: 12),
              _buildMultiCitySegment(idx, seg),
              if (idx < _segments.length - 1) const Divider(height: 32),
            ],
          );
        }).toList(),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => setState(() => _segments.add(FlightSegment(from: _segments.last.to, to: mockLocations[4], date: _segments.last.date.add(const Duration(days: 7))))),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Flight'),
        ),
      ],
    );
  }

  Widget _buildMultiCitySegment(int idx, FlightSegment seg) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: InkWell(onTap: () => _selectLocation(true, segmentIndex: idx), child: _buildAdvancedCityPicker('From', seg.from))),
            const SizedBox(width: 16),
            Expanded(child: InkWell(onTap: () => _selectLocation(false, segmentIndex: idx), child: _buildAdvancedCityPicker('To', seg.to))),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(true, segmentIndex: idx),
          child: _buildSearchField(Icons.calendar_today, 'Departure Date', '${seg.date.day} ${_monthName(seg.date.month)}'),
        ),
      ],
    );
  }

  Widget _buildAdvancedCityPicker(String label, Location loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(loc.city, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Text(loc.code, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildSearchField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.safarBlue, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}

class FlightSegment {
  Location from;
  Location to;
  DateTime date;
  FlightSegment({required this.from, required this.to, required this.date});
}

class _LocationPickerModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search city or airport',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppTheme.backgroundGrey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockLocations.length,
              itemBuilder: (context, index) {
                final loc = mockLocations[index];
                return ListTile(
                  leading: const Icon(Icons.flight_takeoff, color: AppTheme.safarBlue),
                  title: Text(loc.city, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${loc.code} - ${loc.airport}'),
                  trailing: Text(loc.country, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  onTap: () => Navigator.pop(context, loc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
