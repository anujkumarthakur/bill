import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class PhoneService {
  static Future<void> showPhoneInputDialog(BuildContext context) async {
    final numberCtrl = TextEditingController();
    final number = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Phone Number'),
        content: TextField(
          controller: numberCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'e.g. +918687578875',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, numberCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (number == null || number.isEmpty) return;

    try {
      final channel = MethodChannel('com.example.bill_update_app/device');
      final deviceId = await channel.invokeMethod<String>('getDeviceId');
      await http.post(
        Uri.parse('$apiBaseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'phone_number': number,
        }),
      );
    } catch (_) {}
  }
}
