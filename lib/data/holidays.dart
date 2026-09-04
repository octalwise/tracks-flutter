import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    http.Response res;

    if (kIsWeb) {
      final url = Uri.https('tracks-api.octalwise.com', '/caltrain/holiday');
      final token = const String.fromEnvironment('API_KEY');
      res = await http.get(url, headers: {'Authorization': token});
    } else {
      final url = Uri.https('www.caltrain.com', '/schedules/holiday-service-schedules');
      res = await http.get(url);
    }

    final data = utf8.decode(res.bodyBytes, allowMalformed: true);
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
    return holidays.any((h) {
      return h.day == date.day && h.month == date.month;
    });
  }
}
