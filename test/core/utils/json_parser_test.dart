import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/utils/json_parser.dart';

void main() {
  group('JsonParser', () {
    test('parseInt should return parsed integer value', () {
      final json = {'count': 10};
      final result = JsonParser.parseInt(json, 'count');
      expect(result, 10);
    });

    test('parseInt should return default value for missing key', () {
      final json = {'other': 'value'};
      final result = JsonParser.parseInt(json, 'count', defaultValue: 5);
      expect(result, 5);
    });

    test('parseDouble should return parsed double value', () {
      final json = {'temperature': 25.5};
      final result = JsonParser.parseDouble(json, 'temperature');
      expect(result, 25.5);
    });

    test('parseDouble should return default value for missing key', () {
      final json = {'other': 'value'};
      final result = JsonParser.parseDouble(
        json,
        'temperature',
        defaultValue: 20.0,
      );
      expect(result, 20.0);
    });

    test('parseString should return parsed string value', () {
      final json = {'name': 'Test City'};
      final result = JsonParser.parseString(json, 'name');
      expect(result, 'Test City');
    });

    test('parseString should return default value for missing key', () {
      final json = {'other': 'value'};
      final result = JsonParser.parseString(
        json,
        'name',
        defaultValue: 'Unknown',
      );
      expect(result, 'Unknown');
    });

    test('parseDateTime should return parsed DateTime value', () {
      final timestamp = 1617292800; // 2021-04-01 12:00:00 UTC
      final json = {'timestamp': timestamp};
      final result = JsonParser.parseDateTime(json, 'timestamp');
      expect(result, DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
    });

    test('parseList should return parsed list of values', () {
      final json = {
        'items': [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
      };

      final result = JsonParser.parseList(
        json,
        'items',
        (item) => (item as Map<String, dynamic>)['name'] as String,
      );

      expect(result, ['Item 1', 'Item 2']);
    });

    test('parseList should return empty list for missing key', () {
      final json = {'other': 'value'};
      final result = JsonParser.parseList(
        json,
        'items',
        (item) => item.toString(),
      );

      expect(result, []);
    });

    test('getNestedObject should return nested object', () {
      final json = {
        'user': {'id': 1, 'name': 'John'},
      };

      final result = JsonParser.getNestedObject(json, 'user');
      expect(result, {'id': 1, 'name': 'John'});
    });

    test('getNestedObject should return null for missing key', () {
      final json = {'other': 'value'};
      final result = JsonParser.getNestedObject(json, 'user');
      expect(result, null);
    });

    test('getFirstListItem should return first item of list', () {
      final json = {
        'items': ['Item 1', 'Item 2'],
      };

      final result = JsonParser.getFirstListItem(json, 'items');
      expect(result, 'Item 1');
    });

    test('getFirstListItem should return null for missing key', () {
      final json = {'other': 'value'};
      final result = JsonParser.getFirstListItem(json, 'items');
      expect(result, null);
    });

    test('getFirstListItem should return null for empty list', () {
      final json = {'items': []};
      final result = JsonParser.getFirstListItem(json, 'items');
      expect(result, null);
    });
  });
}
