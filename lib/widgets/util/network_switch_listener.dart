import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kover/l10n/app_localizations.dart';

class NetworkSwitchNotifier {
  static final instance = NetworkSwitchNotifier._();
  NetworkSwitchNotifier._();

  final _controller = StreamController<String>.broadcast();
  Stream<String> get stream => _controller.stream;

  void notify(String from, String to) {
    _controller.add('$from → $to');
  }
}

class NetworkSwitchListener extends StatefulWidget {
  final Widget child;

  const NetworkSwitchListener({super.key, required this.child});

  @override
  State<NetworkSwitchListener> createState() => _NetworkSwitchListenerState();
}

class _NetworkSwitchListenerState extends State<NetworkSwitchListener> {
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = NetworkSwitchNotifier.instance.stream.listen((event) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.networkSwitched} ($event)'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
