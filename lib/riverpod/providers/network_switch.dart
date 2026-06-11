import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_switch.g.dart';

@Riverpod(keepAlive: true)
class NetworkSwitchNotifier extends _$NetworkSwitchNotifier {
  @override
  String build() => '';

  void notify(String from, String to) {
    state = '$from → $to';
    Timer(const Duration(seconds: 1), () {
      state = '';
    });
  }
}
