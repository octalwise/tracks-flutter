import 'package:json_annotation/json_annotation.dart';

part 'station_info.g.dart';

@JsonSerializable()
class StationInfo {
  final String name;
  final int north;
  final int south;

  StationInfo({
    required this.name,
    required this.north,
    required this.south,
  });

  factory StationInfo.fromJson(Map<String, dynamic> json) => _$StationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StationInfoToJson(this);
}
