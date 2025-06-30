import 'package:json_annotation/json_annotation.dart';

part 'stop.g.dart';

@JsonSerializable()
class Stop implements Comparable<Stop> {
  final int station;

  @UnixConverter()
  final DateTime scheduled;

  @UnixConverter()
  final DateTime expected;

  Stop({
    required this.station,
    required this.scheduled,
    required this.expected,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);

  @override
  int compareTo(Stop other) {
    return expected.compareTo(other.expected);
  }

  Map<String, dynamic> toJson() => _$StopToJson(this);
}

class UnixConverter implements JsonConverter<DateTime, int> {
  const UnixConverter();

  @override
  DateTime fromJson(int val) => DateTime.fromMillisecondsSinceEpoch(val * 1000);

  @override
  int toJson(DateTime obj) => obj.millisecondsSinceEpoch ~/ 1000;
}
