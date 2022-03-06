import 'package:intl/intl.dart';
import 'package:swiss_knife/swiss_knife.dart';

abstract class DateAdapter {
  static bool verbose = false;

  static void _log(String method, String msg) {
    if (!verbose) return;
    print('DateAdapter.$method> $msg');
  }

  static int create(dynamic date) {
    var dateTime = parseDateTime(date)!;
    _log('create', '$date >> $dateTime');
    return dateTime.millisecondsSinceEpoch;
  }

  static int parse(dynamic date, dynamic format) {
    var dateTime = parseDateTime(date)!;
    _log('parse', '$date ; $format >> $dateTime');
    return dateTime.millisecondsSinceEpoch;
  }

  static String format(dynamic time, dynamic format) {
    var formatStr = format != null ? '$format' : '';

    if (formatStr.isNotEmpty) {
      formatStr = formatStr.replaceAllMapped(
          RegExp(r'(?:\[(.*)\]|(YYYY|YY|DD|D)|(Do)|(SSS))'), (m) {
        if (m[1] != null) {
          return "'${m[1]}'";
        } else if (m[2] != null) {
          return m[2]!.toLowerCase();
        } else if (m[3] != null) {
          return 'dd';
        } else if (m[4] != null) {
          return '';
        } else {
          return m[0]!;
        }
      });
    }

    var dateFormat = formatStr.isNotEmpty
        ? DateFormat(formatStr)
        : DateFormat.yMd().add_jm();

    var dateTime = parseDateTime(time)!;

    var formatted = dateFormat.format(dateTime);
    _log('format', '$time ; $format >> $formatted');

    return formatted;
  }

  static int? startOf(dynamic time, dynamic unit, dynamic weekday) {
    var unitStr = '$unit'.toLowerCase().trim();
    var dateTime = parseDateTime(time);

    DateTime? start;

    if (unitStr == 'isoweek') {
      DateTimeWeekDay? weekFirstDay;
      if (weekday is num) {
        weekFirstDay = getDateTimeWeekDay(weekday.toInt());
      } else if (weekday is String) {
        weekFirstDay = getDateTimeWeekDayByName(weekday);
      }

      var dateTimeRange =
          getDateTimeRange(DateRangeType.THIS_WEEK, dateTime, weekFirstDay);

      start = dateTimeRange.a;
    } else {
      start = getDateTimeStartOf(dateTime!, unitStr);
    }

    _log('startOf', '$time ; $unit ; $weekday >> $start');
    return start?.millisecondsSinceEpoch;
  }

  static int? endOf(dynamic time, dynamic unit) {
    var unitStr = '$unit'.toLowerCase().trim();
    var dateTime = parseDateTime(time)!;

    var end = getDateTimeEndOf(dateTime, unitStr);

    _log('endOf', '$time ; $unit >> $end');
    return end?.millisecondsSinceEpoch;
  }

  static int add(dynamic time, dynamic amount, dynamic unit) {
    var dateTime = parseDateTime(time);
    var duration = parseDuration('$unit', parseInt(amount)!);
    var added = duration != null ? dateTime!.add(duration) : dateTime!;

    _log('endOf', '$time ; $amount ; $unit >> $added');
    return added.millisecondsSinceEpoch;
  }

  static double diff(dynamic max, dynamic min, dynamic unit) {
    var dateTime1 = parseDateTime(max)!;
    var dateTime2 = parseDateTime(min)!;

    var diff = dateTime1.difference(dateTime2);

    var unitParsed = parseUnit(unit);
    if (unitParsed == null) throw ArgumentError("Can't parse unit: $unit");

    var res = diff.inMilliseconds / getUnitAsMilliseconds(unitParsed);

    _log('diff', '$max ; $min ; $unit >> $res');
    return res;
  }
}
