import 'package:flutter/material.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const CalculatorScreen(dark: true), // Я ТАК ПОНЯЛ ТАК ЗАДАЮТСЯ ТЕМЫ
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool dark;
  const CalculatorScreen({super.key, this.dark = true});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

enum Op { add, sub, mul, div }

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ВОЗМОЖНЫЕ СОСТАЯНИЯ
  String _current = '0';
  String? _first;
  Op? _op;
  String _history = '';

  // ДОП СИМВОЛЫ КАК В ДИЗАЙНЕ
  String get _display => _current.replaceAll('.', ',');
  String _fmt(num v) {
    final s = v.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  void _clearAll() {
    setState(() {
      _current = '0';
      _first = null;
      _op = null;
      _history = '';
    });
  }

  void _onDigit(String d) {
    setState(() {
      if (_current == '0') {
        _current = d;
      } else {
        _current += d;
      }
    });
  }

  void _onDecimal() {
    if (_current.contains('.')) return;
    setState(() => _current += '.');
  }

  void _onToggleSign() {
    setState(() {
      if (_current.startsWith('-')) {
        _current = _current.substring(1);
      } else if (_current != '0') {
        _current = '-$_current';
      }
    });
  }

  void _onPercent() {
    final v = double.tryParse(_current.replaceAll(',', '.')) ?? 0.0;
    setState(() => _current = _fmt(v / 100));
  }

  void _onOperator(Op op) {
    final cur = double.tryParse(_current.replaceAll(',', '.'));
    if (cur == null) return;

    setState(() {
      // ЛОГИКА ИЗМЕНЕНИЯ ОПЕРАТОРА
      if (_first != null && _current == '0') {
        _op = op;
        final sym = _sym(op);
        _history = '${_first!.replaceAll('.', ',')} $sym';
        return;
      }

      _first = _current;
      _op = op;
      final sym = _sym(op);
      _history = '${_first!.replaceAll('.', ',')} $sym';
      _current = '0';
    });
  }

  String _sym(Op op) => switch (op) { Op.add => '+', Op.sub => '−', Op.mul => '×', Op.div => '÷' };

  void _onEquals() {
    if (_first == null || _op == null) return;

    final a = double.tryParse(_first!.replaceAll(',', '.')) ?? 0.0;
    final b = double.tryParse(_current.replaceAll(',', '.')) ?? 0.0;

    num res;
    switch (_op!) {
      case Op.add:
        res = a + b;
        break;
      case Op.sub:
        res = a - b;
        break;
      case Op.mul:
        res = a * b;
        break;
      case Op.div:
        if (b == 0) {
          setState(() {
            _history = '';
            _current = 'Error';
            _first = null;
            _op = null;
          });
          return;
        }
        res = a / b;
        break;
    }

    setState(() {
      _history = '${_first!.replaceAll('.', ',')} ${_sym(_op!)} ${_current.replaceAll('.', ',')}';
      _current = _fmt(res);
      _first = null;
      _op = null;
    });
  }

  // --------- UI ---------
  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF0E121A) : const Color(0xFFF1F3F6);
    final txtMain = dark ? Colors.white : const Color(0xFF1B1F2A);
    final txtSub = dark ? const Color(0xFF96A0B5) : const Color(0xFF8C97AD);
    final keyBg = dark ? const Color(0xFF171C26) : Colors.white;
    final keyAlt = dark ? const Color(0xFF2A3140) : const Color(0xFFE9EDF4);
    final opBg = const Color(0xFFFF8A1E);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 12),
              // ИСТОРИЯ КРЧ
              Text(_history.isEmpty ? ' ' : _history, style: TextStyle(fontSize: 18, color: txtSub)),
              const SizedBox(height: 8),
              // КРУПНЫЙ БЕЛЫЙ ОСНОВНОЙ
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('= ', style: TextStyle(fontSize: 28, color: txtSub)),
                  Flexible(
                    child: Text(
                      _display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: txtMain),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // КНОПОЧКИ
              _row([
                _btn('C', keyAlt, onTap: _clearAll),
                _btn('±', keyAlt, onTap: _onToggleSign),
                _btn('%', keyAlt, onTap: _onPercent),
                _btn('÷', opBg, onTap: () => _onOperator(Op.div), fg: Colors.white),
              ]),
              const SizedBox(height: 12),
              _row([
                _btn('7', keyBg, onTap: () => _onDigit('7')),
                _btn('8', keyBg, onTap: () => _onDigit('8')),
                _btn('9', keyBg, onTap: () => _onDigit('9')),
                _btn('×', opBg, onTap: () => _onOperator(Op.mul), fg: Colors.white),
              ]),
              const SizedBox(height: 12),
              _row([
                _btn('4', keyBg, onTap: () => _onDigit('4')),
                _btn('5', keyBg, onTap: () => _onDigit('5')),
                _btn('6', keyBg, onTap: () => _onDigit('6')),
                _btn('−', opBg, onTap: () => _onOperator(Op.sub), fg: Colors.white),
              ]),
              const SizedBox(height: 12),
              _row([
                _btn('1', keyBg, onTap: () => _onDigit('1')),
                _btn('2', keyBg, onTap: () => _onDigit('2')),
                _btn('3', keyBg, onTap: () => _onDigit('3')),
                _btn('+', opBg, onTap: () => _onOperator(Op.add), fg: Colors.white),
              ]),
              const SizedBox(height: 12),
              _row([
                _btn('0', keyBg, onTap: () => _onDigit('0'), wide: true),
                _btn('.', keyBg, onTap: _onDecimal),
                _btn('=', opBg, onTap: _onEquals, fg: Colors.white),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i != 0) const SizedBox(width: 12),
          Expanded(child: children[i]),
        ]
      ],
    );
  }

  Widget _btn(
      String label,
      Color bg, {
        required VoidCallback onTap,
        Color? fg,
        bool wide = false,
      }) {
    final dark = widget.dark;
    final textColor = fg ?? (dark ? const Color(0xFFE6EBF5) : const Color(0xFF1B1F2A));
    final radius = 18.0;

    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            // НЕМНОГО ТЕНЕЙ ДЛЯ КРАСОТЫ
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.35 : 0.08),
              offset: const Offset(0, 6),
              blurRadius: 14,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(dark ? 0.06 : 0.9),
              offset: const Offset(0, -1),
              blurRadius: 6,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Text(label, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor)),
      ),
    );

    if (wide) {
      return Row(children: [Expanded(flex: 2, child: child), const SizedBox(width: 12)]);
    }
    return child;
  }
}
