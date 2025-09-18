import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4';

  static Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest/$baseCurrency'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
          data['rates'].map((key, value) => MapEntry(key, value.toDouble()))
        );
        return rates;
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<double> convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest/$fromCurrency'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];

        if (rates[toCurrency] != null) {
          final rate = rates[toCurrency].toDouble();
          return amount * rate;
        } else {
          throw Exception('Currency $toCurrency not found');
        }
      } else {
        throw Exception('Failed to convert currency: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<DateTime> getLastUpdateTime() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest/USD'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['date'] != null) {
          return DateTime.parse(data['date']);
        }
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static List<Map<String, String>> getSupportedCurrencies() {
    return [
      {'code': 'USD', 'name': 'US Dollar', 'country': 'United States', 'flag': '🇺🇸'},
      {'code': 'EUR', 'name': 'Euro', 'country': 'European Union', 'flag': '🇪🇺'},
      {'code': 'GBP', 'name': 'British Pound', 'country': 'United Kingdom', 'flag': '🇬🇧'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'country': 'Japan', 'flag': '🇯🇵'},
      {'code': 'CAD', 'name': 'Canadian Dollar', 'country': 'Canada', 'flag': '🇨🇦'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'country': 'Australia', 'flag': '🇦🇺'},
      {'code': 'CHF', 'name': 'Swiss Franc', 'country': 'Switzerland', 'flag': '🇨🇭'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'country': 'China', 'flag': '🇨🇳'},
      {'code': 'SEK', 'name': 'Swedish Krona', 'country': 'Sweden', 'flag': '🇸🇪'},
      {'code': 'NZD', 'name': 'New Zealand Dollar', 'country': 'New Zealand', 'flag': '🇳🇿'},
      {'code': 'MXN', 'name': 'Mexican Peso', 'country': 'Mexico', 'flag': '🇲🇽'},
      {'code': 'SGD', 'name': 'Singapore Dollar', 'country': 'Singapore', 'flag': '🇸🇬'},
      {'code': 'HKD', 'name': 'Hong Kong Dollar', 'country': 'Hong Kong', 'flag': '🇭🇰'},
      {'code': 'NOK', 'name': 'Norwegian Krone', 'country': 'Norway', 'flag': '🇳🇴'},
      {'code': 'TRY', 'name': 'Turkish Lira', 'country': 'Turkey', 'flag': '🇹🇷'},
      {'code': 'ZAR', 'name': 'South African Rand', 'country': 'South Africa', 'flag': '🇿🇦'},
      {'code': 'INR', 'name': 'Indian Rupee', 'country': 'India', 'flag': '🇮🇳'},
      {'code': 'BRL', 'name': 'Brazilian Real', 'country': 'Brazil', 'flag': '🇧🇷'},
      {'code': 'RUB', 'name': 'Russian Ruble', 'country': 'Russia', 'flag': '🇷🇺'},
      {'code': 'KRW', 'name': 'South Korean Won', 'country': 'South Korea', 'flag': '🇰🇷'},
      {'code': 'PLN', 'name': 'Polish Zloty', 'country': 'Poland', 'flag': '🇵🇱'},
      {'code': 'DKK', 'name': 'Danish Krone', 'country': 'Denmark', 'flag': '🇩🇰'},
      {'code': 'CZK', 'name': 'Czech Koruna', 'country': 'Czech Republic', 'flag': '🇨🇿'},
      {'code': 'HUF', 'name': 'Hungarian Forint', 'country': 'Hungary', 'flag': '🇭🇺'},
      {'code': 'ILS', 'name': 'Israeli Shekel', 'country': 'Israel', 'flag': '🇮🇱'},
      {'code': 'CLP', 'name': 'Chilean Peso', 'country': 'Chile', 'flag': '🇨🇱'},
      {'code': 'PHP', 'name': 'Philippine Peso', 'country': 'Philippines', 'flag': '🇵🇭'},
      {'code': 'AED', 'name': 'UAE Dirham', 'country': 'United Arab Emirates', 'flag': '🇦🇪'},
      {'code': 'THB', 'name': 'Thai Baht', 'country': 'Thailand', 'flag': '🇹🇭'},
      {'code': 'MYR', 'name': 'Malaysian Ringgit', 'country': 'Malaysia', 'flag': '🇲🇾'},
    ];
  }
}