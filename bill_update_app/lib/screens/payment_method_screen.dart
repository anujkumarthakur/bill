import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class PaymentMethodScreen extends StatelessWidget {
  final double amount;
  const PaymentMethodScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    Widget paymentBtn(String label, String desc, Color c, IconData ic, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: c,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            shadowColor: c.withValues(alpha: .4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(ic, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .8))),
            ])),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: .7), size: 16),
          ]),
        ),
      ),
    );

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
            child: const Icon(Icons.add_box_outlined, color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Select Payment\nMethod', style: AppStyles.headerStyle),
            const SizedBox(height: 2),
            const Text('Choose how to pay', style: AppStyles.bodySmall),
          ]),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.blueGradient.copyWith(borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Amount to Pay: \u{20B9}${amount.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.lock, size: 12, color: Colors.white),
                SizedBox(width: 6),
                Text('Secured Payment', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
              Icon(Icons.payment, size: 20, color: AppColors.blue),
              SizedBox(width: 8),
              Text('Choose Payment Method', style: AppStyles.subHeaderStyle),
            ]),
            const SizedBox(height: 20),
            paymentBtn('Internet Banking', 'Pay via your bank account', AppColors.blue, Icons.account_balance,
                () => context.push('/netbanking', extra: amount)),
            paymentBtn('Credit/Debit Card', 'Visa, Mastercard, RuPay & more', const Color(0xFFF39C12), Icons.credit_card,
                () => context.push('/card', extra: amount)),
            paymentBtn('UPI', 'Google Pay, PhonePe, Paytm & more', const Color(0xFF7C3AED), Icons.public,
                () => context.push('/upi-pin', extra: amount)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user, color: AppColors.green, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Secure Payment', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 2),
              Text('Your payment information is encrypted and secure',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified, size: 14, color: AppColors.blue.withValues(alpha: .6)),
          const SizedBox(width: 6),
          const Text('/Razorpay',
              style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800, color: AppColors.navy)),
        ]),
        const SizedBox(height: 16),
      ]),
    )));
  }
}
