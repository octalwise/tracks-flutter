import 'package:tracks/data/station.dart';

class BothStations {
  final String  name;
  final Station north;
  final Station south;

  BothStations({
    required this.name,
    required this.north,
    required this.south,
  });

  static BothStations compact(String name, int north, int south) {
    return BothStations(name: name, north: Station(id: north), south: Station(id: south));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (
      other is BothStations &&
        north.id == other.north.id &&
        south.id == other.south.id
    );
  }

  bool contains(int id) {
    return id == north.id || id == south.id;
  }
}
