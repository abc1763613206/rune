import 'package:rune/utils/router/base_route_entry.dart';

class ModalRouteEntry extends BaseRouteEntry {
  final (bool, dynamic) Function()? canPop;

  ModalRouteEntry({
    required super.name,
    super.arguments,
    this.canPop,
  });
}