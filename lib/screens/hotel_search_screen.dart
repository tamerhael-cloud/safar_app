import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/flight_data.dart';
import 'hotel_results_screen.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  Location _location = mockLocations[0]; // Default location
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 7));
  int _nights = 2;
  int _rooms = 1;
  int _adults = 2;
  int _children = 0;

  void _selectLocation() async {
    final Location? selected = await showModalBottomSheet<Location>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerModal(),
    );

    if (selected != null) {
      setState(() => _location = selected);
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _checkInDate = picked);
    }
  }

  void _showGuestPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _GuestPickerModal(
        initialRooms: _rooms,
        initialAdults: _adults,
        initialChildren: _children,
        onChanged: (r, a, c) {
          setState(() {
            _rooms = r;
            _adults = a;
            _children = c;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Search Hotels', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: _selectLocation,
                    child: _buildSearchField(Icons.location_on_outlined, 'Destination', '${_location.city}, ${_location.country}'),
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: _buildSearchField(Icons.calendar_today, 'Check-in', 
                            '${_checkInDate.day} ${_monthName(_checkInDate.month)}'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildNightCounter(),
                    ],
                  ),
                  const Divider(height: 32),
                  InkWell(
                    onTap: _showGuestPicker,
                    child: _buildSearchField(Icons.person_outline, 'Rooms & Guests', '$_rooms Room, ${_adults + _children} Guests'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HotelResultsScreen()));
                    },
                    child: const Text('Search Hotels'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNightCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () {
              if (_nights > 1) setState(() => _nights--);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text('$_nights', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Nights', style: TextStyle(fontSize: 10, color: AppTheme.textGrey)),
              ],
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => setState(() => _nights++),
          ),
        ],
      ),
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

class _LocationPickerModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search city or hotel',
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
                  leading: const Icon(Icons.location_on_outlined, color: AppTheme.safarBlue),
                  title: Text(loc.city, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(loc.country),
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

class _GuestPickerModal extends StatefulWidget {
  final int initialRooms;
  final int initialAdults;
  final int initialChildren;
  final Function(int, int, int) onChanged;

  const _GuestPickerModal({
    required this.initialRooms,
    required this.initialAdults,
    required this.initialChildren,
    required this.onChanged,
  });

  @override
  State<_GuestPickerModal> createState() => _GuestPickerModalState();
}

class _GuestPickerModalState extends State<_GuestPickerModal> {
  late int r, a, c;

  @override
  void initState() {
    super.initState();
    r = widget.initialRooms;
    a = widget.initialAdults;
    c = widget.initialChildren;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Rooms & Guests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildCounter('Rooms', r, (val) => setState(() => r = val)),
          _buildCounter('Adults', a, (val) => setState(() => a = val)),
          _buildCounter('Children', c, (val) => setState(() => c = val)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              widget.onChanged(r, a, c);
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int val, Function(int) onUpdate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(onPressed: val > 0 ? () => onUpdate(val - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$val', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => onUpdate(val + 1), icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
        ],
      ),
    );
  }
}
