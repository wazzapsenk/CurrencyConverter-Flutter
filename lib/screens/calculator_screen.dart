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
        if (!_hasError && _result != 'Error' && _result != '0') {
          _expression = _result;
        }
      } else {
        // Prevent consecutive operators
        if (_isOperator(value) && _expression.isNotEmpty) {
          String lastChar = _expression.substring(_expression.length - 1);
          if (_isOperator(lastChar)) {
            // Replace the last operator with the new one
            _expression = _expression.substring(0, _expression.length - 1) + value;
          } else {
            _expression += value;
          }
        } else {
          _expression += value;
        }
        _calculateResult();
      }
    });
  }

  bool _isOperator(String char) {
    return ['+', '-', '×', '÷', '*', '/'].contains(char);
  }

  void _calculateResult() {
    if (_expression.isEmpty) {
      _result = '0';
      _hasError = false;
      return;
    }

    // Check if expression is incomplete (ends with operator)
    if (_isIncompleteExpression(_expression)) {
      // Don't show error for incomplete expressions, just keep current result
      _hasError = false;
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

      // Check for invalid results
      if (result.isNaN || result.isInfinite) {
        _result = 'Error';
        _hasError = true;
        return;
      }

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

      _hasError = false;
    } catch (e) {
      // Only show error for actual invalid expressions, not incomplete ones
      if (!_isIncompleteExpression(_expression)) {
        _result = 'Error';
        _hasError = true;
      }
    }
  }

  bool _isIncompleteExpression(String expression) {
    if (expression.isEmpty) return false;

    // Check if expression ends with an operator
    final operators = ['+', '-', '×', '÷', '*', '/', '('];
    final lastChar = expression.trim().substring(expression.trim().length - 1);

    return operators.contains(lastChar);
  }

  String _handlePercentage(String expression) {
    // Simple percentage handling - replace % with /100
    return expression.replaceAll('%', '/100');
  }

  Widget _buildButton(String text, {Color? color, Color? textColor, int flex = 1}) {
    final isOperator = ['+', '-', '×', '÷', '=', '%', 'π'].contains(text);
    final isSpecial = ['C', '⌫'].contains(text);
    final isNumber = '0123456789.00'.contains(text);

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(6),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(20),
          shadowColor: Colors.black.withOpacity(0.3),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _onButtonPressed(text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: _getButtonGradient(text, color, isOperator, isSpecial, isNumber),
                boxShadow: [
                  BoxShadow(
                    color: _getButtonShadowColor(text, color, isOperator, isSpecial),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text == '00' ? 16 : 22,
                    fontWeight: FontWeight.bold,
                    color: _getButtonTextColor(text, textColor, isOperator, isSpecial),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getButtonGradient(String text, Color? color, bool isOperator, bool isSpecial, bool isNumber) {
    final colorScheme = Theme.of(context).colorScheme;

    if (color != null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, color.withOpacity(0.8)],
      );
    }

    if (isSpecial) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.red.shade400, Colors.red.shade600],
      );
    }

    if (isOperator) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.primary, colorScheme.secondary],
      );
    }

    if (text == '=') {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.shade400, Colors.green.shade600],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surface,
        colorScheme.surfaceVariant.withOpacity(0.8),
      ],
    );
  }

  Color _getButtonShadowColor(String text, Color? color, bool isOperator, bool isSpecial) {
    if (color != null) return color.withOpacity(0.4);
    if (isSpecial) return Colors.red.withOpacity(0.4);
    if (isOperator) return Theme.of(context).colorScheme.primary.withOpacity(0.4);
    if (text == '=') return Colors.green.withOpacity(0.4);
    return Colors.black.withOpacity(0.1);
  }

  Color _getButtonTextColor(String text, Color? textColor, bool isOperator, bool isSpecial) {
    if (textColor != null) return textColor;
    if (isSpecial || isOperator || text == '=') return Colors.white;
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator',
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
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Display section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surfaceVariant.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expression display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.3),
                            colorScheme.secondary.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    // Result display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        _result,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _hasError
                              ? Colors.red.shade600
                              : colorScheme.primary,
                          letterSpacing: 1,
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
                        _buildButton('C'),
                        _buildButton('⌫'),
                        _buildButton('('),
                        _buildButton(')'),
                        _buildButton('÷'),
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
                        _buildButton('%'),
                        _buildButton('×'),
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
                        _buildButton('π'),
                        _buildButton('-'),
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
                        _buildButton('+'),
                      ],
                    ),
                  ),
                  // Row 5: 0, Equals
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('0', flex: 2),
                        _buildButton('00'),
                        _buildButton('=', flex: 2),
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