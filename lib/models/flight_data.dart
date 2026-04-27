class Location {
  final String city;
  final String airport;
  final String code;
  final String country;

  Location({
    required this.city,
    required this.airport,
    required this.code,
    required this.country,
  });
}

final List<Location> mockLocations = [
  Location(city: 'Muscat', airport: 'Muscat Intl.', code: 'MCT', country: 'Oman'),
  Location(city: 'Dubai', airport: 'Dubai Intl.', code: 'DXB', country: 'UAE'),
  Location(city: 'Beijing', airport: 'Beijing Capital', code: 'PEK', country: 'China'),
  Location(city: 'London', airport: 'Heathrow', code: 'LHR', country: 'UK'),
  Location(city: 'Paris', airport: 'Charles de Gaulle', code: 'CDG', country: 'France'),
  Location(city: 'New York', airport: 'John F. Kennedy', code: 'JFK', country: 'USA'),
  Location(city: 'Riyadh', airport: 'King Khalid Intl.', code: 'RUH', country: 'Saudi Arabia'),
  Location(city: 'Istanbul', airport: 'Istanbul Airport', code: 'IST', country: 'Turkey'),
  Location(city: 'Bali', airport: 'Ngurah Rai', code: 'DPS', country: 'Indonesia'),
  Location(city: 'Cairo', airport: 'Cairo Intl.', code: 'CAI', country: 'Egypt'),
];
