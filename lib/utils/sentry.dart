import 'dart:async';

import 'package:kover/utils/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> initializeSentry({
  required FutureOr<void> Function() appRunner,
}) async {
  if (Env.sentryDsn.isEmpty) {
    await appRunner();
    return;
  }

  await SentryFlutter.init(
    sentryOptionsConfiguration,
    appRunner: appRunner,
  );
}

FutureOr<void> sentryOptionsConfiguration(SentryFlutterOptions options) {
  options.dsn = Env.sentryDsn;
  options.sendDefaultPii = false;
  options.enableLogs = true;
  options.enableTombstone = true;
  const isDebug = bool.fromEnvironment('dart.vm.product') == false;
  options.tracesSampleRate = isDebug ? 1.0 : 0.2;
  // ignore: experimental_member_use
  options.profilesSampleRate = isDebug ? 1.0 : 0.1;
  options.replay.sessionSampleRate = isDebug ? 0.1 : 0.0;
  options.replay.onErrorSampleRate = 1.0;
}
