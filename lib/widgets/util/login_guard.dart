import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/riverpod/providers/auth.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/settings/credentials.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginGuard extends ConsumerWidget {
  final Widget child;

  const LoginGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginStatus = ref.watch(loginStatusProvider);

    return switch (loginStatus) {
      .loggedIn => child,
      .loading => const Center(child: CircularProgressIndicator()),
      .noCredentials => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.userLock,
                size: LayoutConstants.largerIcon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              Text(
                context.l10n.notSignedIn,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutConstants.smallerPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: Text(
                  context.l10n.noCredentialsConfigured,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              FilledButton(
                onPressed: () => const SettingsRoute().go(context),
                child: Text(context.l10n.openSettings),
              ),
            ],
          ),
        ),
      ),
      .error => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.triangleAlert,
                size: LayoutConstants.largerIcon,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              Text(
                context.l10n.connectionError,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutConstants.smallerPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: Text(
                  context.l10n.failedToFetchUser,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(currentUserProvider),
                    icon: Icon(
                      LucideIcons.rotateCcw,
                      size: LayoutConstants.smallIcon,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(context.l10n.retry),
                  ),
                  const SizedBox(height: LayoutConstants.smallPadding),
                  FilledButton.icon(
                    onPressed: () => const SettingsRoute().go(context),
                    icon: Icon(
                      LucideIcons.settings,
                      size: LayoutConstants.smallIcon,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(context.l10n.openSettings),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    };
  }
}
