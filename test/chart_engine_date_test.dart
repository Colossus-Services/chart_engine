import 'package:chart_engine/src/chart_engine_date.dart';
import 'package:test/test.dart';

void main() {
  group('DateAdapter', () {
    final date = DateTime(2020, 3, 15, 13, 45, 30);
    final millis = date.millisecondsSinceEpoch;

    test('create', () {
      expect(DateAdapter.create(date), equals(millis));
      expect(DateAdapter.create(millis), equals(millis));
    });

    test('parse', () {
      expect(DateAdapter.parse(date, null), equals(millis));
      expect(
        DateAdapter.parse('2020-03-15', null),
        equals(DateTime(2020, 3, 15).millisecondsSinceEpoch),
      );
    });

    test('format: moment.js style tokens', () {
      expect(DateAdapter.format(millis, 'YYYY-MM-DD'), equals('2020-03-15'));
      expect(DateAdapter.format(millis, 'YY/MM/DD'), equals('20/03/15'));
      expect(DateAdapter.format(millis, 'HH:mm:ss.SSS'), equals('13:45:30.'));
      expect(DateAdapter.format(millis, '[Day] D'), equals('Day 15'));
      expect(DateAdapter.format(millis, 'MMM Do'), equals('Mar 15'));
      expect(DateAdapter.format(millis, '[Q] YYYY [W]'), equals('Q 2020 W'));
    });

    test('format: default', () {
      // `intl` may use a narrow no-break space before AM/PM.
      var expected = RegExp(r'^3/15/2020 1:45\sPM$');
      expect(DateAdapter.format(millis, null), matches(expected));
      expect(DateAdapter.format(millis, ''), matches(expected));
    });

    test('startOf / endOf', () {
      expect(
        DateAdapter.startOf(millis, 'day', null),
        equals(DateTime(2020, 3, 15).millisecondsSinceEpoch),
      );
      expect(
        DateAdapter.startOf(millis, 'month', null),
        equals(DateTime(2020, 3, 1).millisecondsSinceEpoch),
      );
      expect(
        DateAdapter.startOf(millis, 'year', null),
        equals(DateTime(2020).millisecondsSinceEpoch),
      );
      expect(
        DateAdapter.startOf(millis, 'hour', null),
        equals(DateTime(2020, 3, 15, 13).millisecondsSinceEpoch),
      );

      expect(
        DateAdapter.endOf(millis, 'day'),
        equals(DateTime(2020, 3, 15, 23, 59, 59, 999).millisecondsSinceEpoch),
      );
    });

    test('startOf isoWeek', () {
      // 2020-03-15 is a Sunday.
      var start = DateTime.fromMillisecondsSinceEpoch(
        DateAdapter.startOf(millis, 'isoWeek', 1)!,
      );
      expect(start.weekday, equals(DateTime.monday));
      expect(start, equals(DateTime(2020, 3, 9)));
    });

    test('add', () {
      expect(
        DateAdapter.add(millis, 2, 'day'),
        equals(date.add(Duration(days: 2)).millisecondsSinceEpoch),
      );
      expect(
        DateAdapter.add(millis, 3, 'hour'),
        equals(date.add(Duration(hours: 3)).millisecondsSinceEpoch),
      );
    });

    test('diff', () {
      var later = date.add(Duration(hours: 36));
      expect(DateAdapter.diff(later, date, 'hour'), equals(36));
      expect(DateAdapter.diff(later, date, 'day'), equals(1.5));
      expect(() => DateAdapter.diff(later, date, 'foo'), throwsArgumentError);
    });
  });
}
