import 'package:deriv_explore_markets/deriv_explore_markets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DerivExploreMarketsConfig', () {
    test('creates config with required parameters', () {
      const config = DerivExploreMarketsConfig(
        webSocketUrl: 'wss://ws.example.com/websockets/v3?app_id=TEST_APP_ID',
      );

      expect(
        config.webSocketUrl,
        'wss://ws.example.com/websockets/v3?app_id=TEST_APP_ID',
      );
      expect(config.autoConnect, true);
      expect(config.maxReconnectAttempts, 5);
      expect(config.reconnectDelay, const Duration(seconds: 3));
    });

    test('creates config with custom parameters', () {
      const config = DerivExploreMarketsConfig(
        webSocketUrl: 'wss://test.example.com',
        autoConnect: false,
        maxReconnectAttempts: 10,
        reconnectDelay: Duration(seconds: 5),
      );

      expect(config.webSocketUrl, 'wss://test.example.com');
      expect(config.autoConnect, false);
      expect(config.maxReconnectAttempts, 10);
      expect(config.reconnectDelay, const Duration(seconds: 5));
    });

    test('copyWith creates new config with updated values', () {
      const original = DerivExploreMarketsConfig(
        webSocketUrl: 'wss://original.example.com',
      );

      final updated = original.copyWith(
        webSocketUrl: 'wss://updated.example.com',
        autoConnect: false,
      );

      expect(updated.webSocketUrl, 'wss://updated.example.com');
      expect(updated.autoConnect, false);
      expect(updated.maxReconnectAttempts, original.maxReconnectAttempts);
    });
  });
}
