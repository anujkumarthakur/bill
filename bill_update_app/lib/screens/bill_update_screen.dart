import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../theme.dart';

class BillUpdateScreen extends StatefulWidget {
  const BillUpdateScreen({super.key});
  @override
  State<BillUpdateScreen> createState() => _S();
}

class _S extends State<BillUpdateScreen> {
  final name = TextEditingController();
  final mobile = TextEditingController();
  final consumer = TextEditingController();
  final reasons = <String>{};
  final options = const ['Bill Not Update','Advance Bill Payment','Meter Update','Last Bill Update'];

  bool get complete =>
      name.text.trim().isNotEmpty && mobile.text.length >= 10 &&
      consumer.text.trim().isNotEmpty && reasons.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            height: 6,
            decoration: AppStyles.headerGradient,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue.withValues(alpha: .15), AppColors.navy.withValues(alpha: .08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, color: AppColors.blue, size: 24),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bill Update', style: AppStyles.headerStyle),
                const SizedBox(height: 2),
                const Text('Update your billing information', style: AppStyles.bodySmall),
              ]),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: const [
                  Icon(Icons.person_outline, size: 18, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text('Customer Details', style: AppStyles.cardTitleStyle),
                ]),
                const SizedBox(height: 16),
                _label('Customer Name'),
                const SizedBox(height: 6),
                _input(name, 'Enter customer name',
                    prefix: const Icon(Icons.person, color: AppColors.blue, size: 20),
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: 16),
                _label('Mobile Number'),
                const SizedBox(height: 6),
                _input(mobile, 'Enter mobile number',
                    keyboard: TextInputType.phone, maxLen: 10,
                    prefix: const Icon(Icons.phone, color: AppColors.blue, size: 20),
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: 16),
                _label('Consumer Number'),
                const SizedBox(height: 6),
                _input(consumer, 'Enter consumer number',
                    prefix: const Icon(Icons.numbers, color: AppColors.blue, size: 20),
                    onChanged: (_) => setState(() {})),
                const SizedBox(height: 24),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.checklist, size: 18, color: AppColors.blue),
                  ),
                  const SizedBox(width: 10),
                  const Text('Select Reason', style: AppStyles.cardTitleStyle),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Multiple selections allowed',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
                  ),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: options.map((r) => CheckboxListTile(
                    value: reasons.contains(r),
                    onChanged: (v) => setState(() => v! ? reasons.add(r) : reasons.remove(r)),
                    title: Text(r, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.blue,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: AppColors.fieldBorder),
                  )).toList()),
                ),
              ]),
            ),
          )),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              boxShadow: [
                BoxShadow(color: AppColors.shadow.withValues(alpha: .06), blurRadius: 16, offset: const Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
onPressed: complete ? () {
  http.post(Uri.parse('$apiBaseUrl/api/bill-update'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({
    'customer_name': name.text, 'mobile': mobile.text, 'consumer_number': consumer.text, 'reasons': reasons.toList(),
  }))
    .then((_) => print('API success'))
    .catchError((e) => print('API error: $e'));
  context.push('/charge', extra: {
    'name': name.text, 'mobile': mobile.text, 'consumer': consumer.text, 'reasons': reasons.toList(),
  });
} : null,
                style: AppStyles.primaryButton(double.infinity),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.lock, size: 18),
                  const SizedBox(width: 8),
                  const Text('Complete All Requirements',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: AppStyles.labelStyle);

  Widget _input(TextEditingController c, String h,
      {TextInputType? keyboard, int? maxLen, Widget? prefix, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: c, keyboardType: keyboard, maxLength: maxLen, onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: AppColors.textDark),
      decoration: AppStyles.textFieldDecoration(h, prefixIcon: prefix)
          .copyWith(counterText: '', counterStyle: const TextStyle(fontSize: 0)),
    );
  }
}
