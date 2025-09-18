import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  bool _hasError = false;

  void _onButtonPressed(String value) {
    setState(() {
      _hasError = false;

      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _calculateResult();
        }
      } else if (value == '=') {
        _calculateResult();
        if (!_hasError && _result != 'Error') {
          _expression = _result;
        }
      } else {
        _expression += value;
        _calculateResult();
      }
    });
  }

  void _calculateResult() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }

    try {
      // Replace display symbols with math expression symbols
      String expression = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '3.14159265359');

      // Handle percentage
      expression = _handlePercentage(expression);

      GrammarParser parser = GrammarParser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      // Format the result
      if (result == result.toInt()) {
        _result = result.toInt().toString();
      } else {
        _result = result.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
      }

      // Limit result length
      if (_result.length > 12) {
        double val = double.parse(_result);
        _result = val.toStringAsExponential(5);
      }
    } catch (e) {
      _result = 'Error';
      _hasError = true;
    }
  }

  String _handlePercentage(String expression) {
    // Simple percentage handling - replace % with /100
    return expression.replaceAll('%', '/100');
  }

  Widget _buildButton(String text, {Color? color, Color? textColor, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).colorScheme.surface,
            foregroundColor: textColor ?? Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Display section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expression display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  // Result display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _result,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _hasError ? Colors.red : colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Button section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Row 1: Clear, Backspace, Parentheses, Divide
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('C', color: colorScheme.errorContainer, textColor: colorScheme.onErrorContainer),
                        _buildButton('⌫', color: colorScheme.errorContainer, textColor: colorScheme.onErrorContainer),
                        _buildButton('(', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                        _buildButton(')', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                        _buildButton('÷', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                  // Row 2: 7, 8, 9, Multiply
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('%', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                        _buildButton('×', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                  // Row 3: 4, 5, 6, Subtract
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('π', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                        _buildButton('-', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                  // Row 4: 1, 2, 3, Add
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('.'),
                        _buildButton('+', color: colorScheme.primaryContainer, textColor: colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                  // Row 5: 0, Equals
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('0', flex: 2),
                        _buildButton('00'),
                        _buildButton('=', color: colorScheme.primary, textColor: colorScheme.onPrimary, flex: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}