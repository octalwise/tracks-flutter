import 'package:json_annotation/json_annotation.dart';

part 'alert.g.dart';

@JsonSerializable()
class Alert {
  final String header;
  final String? description;

  Alert({
    required this.header,
    this.description,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}
