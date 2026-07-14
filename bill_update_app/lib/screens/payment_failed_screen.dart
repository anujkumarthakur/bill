import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Center(child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel, size: 64, color: AppColors.red),
          )),
          const SizedBox(height: 16),
          const Center(child: Text('Payment Failed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5))),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppStyles.cardDecoration,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: AppColors.red, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Error Details', style: AppStyles.cardTitleStyle),
              ]),
              const SizedBox(height: 16),
              RichText(text: const TextSpan(style: TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.6), children: [
                TextSpan(text: 'Dear customer your card is not active for domestic '),
                TextSpan(text: 'ECOM transactions', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                TextSpan(text: '. Please use another Debit / credit card / or net banking'),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration.copyWith(
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.security, color: Colors.orange, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Safe Banking Tips', style: AppStyles.cardTitleStyle),
              ]),
              const SizedBox(height: 16),
              _tip('Beware of phishing and fishing Attack - avoid sharing account-related information'),
              const SizedBox(height: 12),
              _tip('Over e-mail and SMS, please read the terms and conditions'),
              const SizedBox(height: 12),
              _tip('Carefully before proceeding'),
            ]),
          ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Back to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              style: AppStyles.primaryButton(double.infinity),
            ),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.copyright, size: 12, color: AppColors.textLight),
            const SizedBox(width: 4),
            const Text('Copyright 2017 Jabbing.com. All Rights Reserved',
                style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ]),
          const SizedBox(height: 16),
        ]),
      )),
    );
  }

  Widget _tip(String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      margin: const EdgeInsets.only(top: 4),
      width: 6, height: 6,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
    ),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4))),
  ]);
}
