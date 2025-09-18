import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double? _convertedAmount;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  final List<Map<String, String>> _currencies = CurrencyService.getSupportedCurrencies();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _amountController.text = '1';
    _convertCurrency();
    _getLastUpdateTime();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convertCurrency() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _convertedAmount = null;
        _errorMessage = null;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
        _convertedAmount = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await CurrencyService.convertCurrency(
        amount,
        _fromCurrency,
        _toCurrency,
      );
      setState(() {
        _convertedAmount = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _convertedAmount = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _getLastUpdateTime() async {
    try {
      final lastUpdate = await CurrencyService.getLastUpdateTime();
      setState(() {
        _lastUpdated = lastUpdate;
      });
    } catch (e) {
      // Ignore error for last update time
    }
  }

  Future<void> _refreshRates() async {
    await _convertCurrency();
    await _getLastUpdateTime();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convertCurrency();
  }

  String _formatCurrency(double amount, String currency) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'INR': return '₹';
      default: return currency;
    }
  }

  Map<String, String> _getCurrencyInfo(String currencyCode) {
    return _currencies.firstWhere(
      (currency) => currency['code'] == currencyCode,
      orElse: () => {'code': currencyCode, 'name': currencyCode, 'flag': '🏳️'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRates,
            tooltip: 'Refresh Rates',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRates,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter amount',
                                errorText: _errorMessage,
                                prefixIcon: Icon(
                                  Icons.monetization_on_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                              ),
                              onChanged: (_) => _convertCurrency(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                child: Card(
                  elevation: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.currency_exchange,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Currency Exchange',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _fromCurrency,
                                        isExpanded: true,
                                        isDense: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                          prefixIcon: Icon(
                                            Icons.account_balance_wallet,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        items: _currencies.map((currency) {
                                          return DropdownMenuItem(
                                            value: currency['code'],
                                            child: Row(
                                              children: [
                                                Text(
                                                  currency['flag']!,
                                                  style: const TextStyle(fontSize: 18),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  currency['code']!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '- ${currency['name']!}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _fromCurrency = value;
                                            });
                                            _convertCurrency();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  const SizedBox(height: 32),
                                  AnimatedRotation(
                                    turns: _selectedIndex / 4,
                                    duration: const Duration(milliseconds: 500),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.secondary,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          _swapCurrencies();
                                          setState(() {
                                            _selectedIndex++;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.swap_horiz,
                                          color: Colors.white,
                                        ),
                                        iconSize: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _toCurrency,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                          prefixIcon: Icon(
                                            Icons.payments,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        items: _currencies.map((currency) {
                                          return DropdownMenuItem(
                                            value: currency['code'],
                                            child: Row(
                                              children: [
                                                Text(
                                                  currency['flag']!,
                                                  style: const TextStyle(fontSize: 18),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  currency['code']!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '- ${currency['name']!}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _toCurrency = value;
                                            });
                                            _convertCurrency();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Card(
                  elevation: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade400,
                                      Colors.green.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Conversion Result',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_isLoading)
                            Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Converting...',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_convertedAmount != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade50,
                                        Colors.green.shade100,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _formatCurrency(_convertedAmount!, _toCurrency),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getCurrencyInfo(_toCurrency)['flag']!,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _toCurrency,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_amountController.text} $_fromCurrency',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatCurrency(_convertedAmount!, _toCurrency),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade50,
                                    Colors.red.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade200, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Error',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calculate_outlined,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Enter an amount to convert',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_lastUpdated != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.schedule,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(_lastUpdated!)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pull down to refresh exchange rates',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}