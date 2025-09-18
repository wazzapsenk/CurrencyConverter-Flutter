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

  static List<String> getSupportedCurrencies() {
    return [
      'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'SEK', 'NZD',
      'MXN', 'SGD', 'HKD', 'NOK', 'TRY', 'ZAR', 'INR', 'BRL', 'RUB', 'KRW',
      'PLN', 'DKK', 'CZK', 'HUF', 'ILS', 'CLP', 'PHP', 'AED', 'THB', 'MYR'
    ];
  }
}