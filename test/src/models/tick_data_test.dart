import 'package:deriv_explore_markets/deriv_explore_markets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickData', () {
    test('fromJson creates TickData correctly', () {
      final json = {
        'tick': {
          'symbol': 'frxEURUSD',
          'quote': 1.08953,
          'ask': 1.08955,
          'bid': 1.08951,
          'epoch': 1699876543,
          'id': 'abc123',
          'pip_size': 5,
        },
      };

      final tickData = TickData.fromJson(json);

      expect(tickData.symbol, 'frxEURUSD');
      expect(tickData.quote, 1.08953);
      expect(tickData.ask, 1.08955);
      expect(tickData.bid, 1.08951);
      expect(tickData.epoch, 1699876543);
      expect(tickData.id, 'abc123');
      expect(tickData.pipSize, 5);
    });

    test('formattedQuote returns correctly formatted string', () {
      final tickData = TickData(
        symbol: 'frxEURUSD',
        quote: 1.08953,
        epoch: 1699876543,
        id: 'abc123',
        pipSize: 5,
      );

      expect(tickData.formattedQuote, '1.08953');
    });

    test('spread calculates correctly when ask and bid are present', () {
      final tickData = TickData(
        symbol: 'frxEURUSD',
        quote: 1.08953,
        epoch: 1699876543,
        id: 'abc123',
        pipSize: 5,
        ask: 1.08955,
        bid: 1.08951,
      );

      expect(tickData.spread, closeTo(0.00004, 0.000001));
    });

    test('spread returns null when ask or bid is missing', () {
      final tickData = TickData(
        symbol: 'frxEURUSD',
        quote: 1.08953,
        epoch: 1699876543,
        id: 'abc123',
        pipSize: 5,
      );

      expect(tickData.spread, isNull);
    });

    test('copyWith creates new instance with updated values', () {
      final original = TickData(
        symbol: 'frxEURUSD',
        quote: 1.08953,
        epoch: 1699876543,
        id: 'abc123',
        pipSize: 5,
      );

      final updated = original.copyWith(quote: 1.09000);

      expect(updated.quote, 1.09000);
      expect(updated.symbol, original.symbol);
      expect(updated.epoch, original.epoch);
    });
  });
}
