import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'package:intl/intl.dart';

class Holiday {
  final int day;
  final int month;

  const Holiday({
    required this.day,
    required this.month,
  });
}

class Holidays {
  final List<Holiday> holidays;

  const Holidays._(this.holidays);

  static Future<Holidays> create() async {
    final url = Uri.https('www.caltrain.com', '/schedules/holiday-service-schedules');
    final res = await http.get(url);

    final data = res.body;
    final doc = html.parse(data);

    final holidays = <Holiday>[];

    for (final row in doc.querySelectorAll('table.holiday-service-schedule tbody tr')) {
      final vals = row.querySelectorAll('td');

      if (vals[2].text != "Weekend Schedule*") {
        continue;
      }

      final formatter = DateFormat('MMMM d');
      final time = formatter.parseStrict(vals[1].text);

      holidays.add(Holiday(day: time.day, month: time.month));
    }

    return Holidays._(holidays);
  }

  bool isHoliday(DateTime date) {
    return this.holidays.any((h) {
      return h.day == date.day && h.month == date.month;
    });
  }
}
