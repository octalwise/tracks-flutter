import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tracks/data/holidays.dart';
import 'package:tracks/widget/utils.dart';

part 'service.g.dart';

enum ServiceType {
  weekday,
  weekend,
  normal;

  static ServiceType from(String service) {
    return service == "weekday" ? ServiceType.weekday : ServiceType.weekend;
  }
}

class ServiceState {
  final ServiceType cur;
  final ServiceType normal;

  const ServiceState({required this.cur, required this.normal});
}

@riverpod
class Service extends _$Service {
  @override
  ServiceState? build() => null;

  void load(Holidays holidays) {
    final normal = normalService(holidays);

    if (state == null) {
      state = ServiceState(cur: normal, normal: normal);
    } else {
      state = ServiceState(cur: state!.cur, normal: normal);
    }
  }

  void toggle() {
    if (state == null) return;

    final service = state!.cur == ServiceType.weekday ? ServiceType.weekend : ServiceType.weekday;
    state = ServiceState(cur: service, normal: state!.normal);
  }

  bool alt() {
    if (state == null) return false;

    return state!.cur != state!.normal;
  }

  bool realService(ServiceType service) {
    if (state == null) return true;
    return service == state!.normal || service == ServiceType.normal;
  }

  bool isService(ServiceType service) {
    if (state == null) return false;

    return service == state!.cur || (service == ServiceType.normal && state!.cur == state!.normal);
  }

  ServiceType normalService(Holidays holidays) {
    final now = tzNow();
    final shifted = now.subtract(const Duration(hours: 3));

    final weekend =
      shifted.weekday == DateTime.saturday || shifted.weekday == DateTime.sunday;

    return
      (weekend || holidays.isHoliday(shifted))
        ? ServiceType.weekend
        : ServiceType.weekday;
  }
}
