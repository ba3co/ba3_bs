import 'package:ba3_bs/counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Counter counter;
  setUp(() {
    counter = Counter();
  });

  group('description', () {
    test('counter value increment', () {
      counter.increment();

      expect(counter.value, 1);
    });

    test('counter value decrement', () {
      counter.decrement();

      expect(counter.value, -1);
    });
  });
}
