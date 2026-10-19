import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'sms_parser_service.dart';
import 'alarm_service.dart';

// Top-level function for background SMS processing
@pragma('vm:entry-point')
void backgroundSmsHandler(SmsMessage message) {
  final body = message.body;
  if (body != null && body.isNotEmpty) {
    debugPrint("[Background SMS Received]: $body");
    final parsed = SmsParserService.parse(body);
    if (parsed != null) {
      debugPrint("[Parsed Background Transaction]: ${parsed.amount} at ${parsed.merchant}");
    }
  }
}

class SmsListenerService {
  static final SmsListenerService _instance = SmsListenerService._internal();
  factory SmsListenerService() => _instance;
  SmsListenerService._internal();

  final Telephony _telephony = Telephony.instance;
  bool _isListening = false;
  Function(ParsedPaymentMessage)? _onTransactionDetected;

  Future<void> startListening({
    required Function(ParsedPaymentMessage) onTransactionDetected,
  }) async {
    _onTransactionDetected = onTransactionDetected;

    if (_isListening) return;

    try {
      // 1. Request SMS Permissions
      final bool? permissionsGranted =
          await _telephony.requestPhoneAndSmsPermissions;

      if (permissionsGranted == true) {
        debugPrint("SMS Permissions granted. Starting real-time listener...");

        // 2. Listen to incoming SMS in foreground and background
        _telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            final body = message.body;
            if (body == null || body.isEmpty) return;

            debugPrint("[Incoming SMS Received in real-time]: $body");
            final parsed = SmsParserService.parse(body);

            if (parsed != null) {
              AlarmService().playChimeSound();
              if (_onTransactionDetected != null) {
                _onTransactionDetected!(parsed);
              }
            }
          },
          onBackgroundMessage: backgroundSmsHandler,
          listenInBackground: true,
        );

        _isListening = true;
      } else {
        debugPrint("SMS Permissions not granted by user.");
      }
    } catch (e) {
      debugPrint("Telephony SMS Listener notice (handled gracefully): $e");
    }
  }
}
