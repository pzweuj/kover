import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/riverpod/providers/client.dart';

class NetworkSwitchListener extends ConsumerWidget {
  final Widget child;

  const NetworkSwitchListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(networkSwitchNotifierProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.networkSwitched} ($next)'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });

    return child;
  }
}
