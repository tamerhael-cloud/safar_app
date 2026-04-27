import 'dart:convert';
import 'package:http/http.dart' as http;

class FlightSearchResult {
  final String airline;
  final String flightNumber;
  final String departure;
  final String arrival;
  final String price;
  final DateTime date;

  FlightSearchResult({
    required this.airline,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.price,
    required this.date,
  });

  factory FlightSearchResult.fromJson(Map<String, dynamic> json) {
    return FlightSearchResult(
      airline: json['airline'] ?? 'Unknown',
      flightNumber: json['flightNumber'] ?? '',
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      price: json['price']?.toString() ?? '0',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
    );
  }
}

class HotelSearchResult {
  final String name;
  final String location;
  final String pricePerNight;
  final double rating;
  final String imageUrl;

  HotelSearchResult({
    required this.name,
    required this.location,
    required this.pricePerNight,
    required this.rating,
    required this.imageUrl,
  });

  factory HotelSearchResult.fromJson(Map<String, dynamic> json) {
    return HotelSearchResult(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      pricePerNight: json['price']?.toString() ?? '0',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class ExternalApiService {
  // Replace these with your actual API credentials
  static const String flightApiUrl = 'https://api.example.com/v1/flights';
  static const String hotelApiUrl = 'https://api.example.com/v1/hotels';
  static const String apiKey = 'YOUR_API_KEY_HERE';

  // Search Flights via External API
  Future<List<FlightSearchResult>> searchFlights({
    required String from,
    required String to,
    required String date,
  }) async {
    try {
      // FOR TESTING: Return mock data if API URL is default
      if (flightApiUrl.contains('example.com')) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate network lag
        return [
          FlightSearchResult(airline: 'Qatar Airways', flightNumber: 'QR102', departure: from, arrival: to, price: '450', date: DateTime.now().add(const Duration(days: 2))),
          FlightSearchResult(airline: 'Emirates', flightNumber: 'EK500', departure: from, arrival: to, price: '520', date: DateTime.now().add(const Duration(days: 3))),
          FlightSearchResult(airline: 'Turkish Airlines', flightNumber: 'TK204', departure: from, arrival: to, price: '380', date: DateTime.now().add(const Duration(days: 5))),
        ];
      }

      final response = await http.get(
        Uri.parse('$flightApiUrl?origin=$from&destination=$to&departureDate=$date'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => FlightSearchResult.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch flights');
      }
    } catch (e) {
      print('API Error: $e');
      return []; // Return empty list on error
    }
  }

  // Search Hotels via External API
  Future<List<HotelSearchResult>> searchHotels({
    required String city,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$hotelApiUrl?city=$city'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => HotelSearchResult.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch hotels');
      }
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }
}
