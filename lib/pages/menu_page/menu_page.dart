import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/pages/menu_page/sliver_libraries.dart';
import 'package:kover/riverpod/managers/download_manager.dart';
import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:kover/riverpod/providers/auth.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/actions_app_bar/actions_app_bar.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MenuPage extends HookConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.read(syncManagerProvider.notifier).syncLibraries();
      return null;
    }, const []);

    final l10n = context.l10n;

    final loggedIn = ref.watch(
      currentUserProvider.select((state) => state.hasValue),
    );

    final isDownloading = ref.watch(
      downloadManagerProvider.select(
        (state) => state.value?.downloadQueue.isNotEmpty ?? false,
      ),
    );

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            ActionsAppBar(
              title: l10n.libraries,
              leadingActions: [
                _AppBarButton(
                  icon: isDownloading
                      ? const Icon(
                          LucideIcons.refreshCw,
                          size: LayoutConstants.smallIcon,
                        ).animate(onPlay: (c) => c.repeat()).rotate(
                            duration: 1500.ms,
                          )
                      : const Icon(
                          LucideIcons.download,
                          size: LayoutConstants.smallIcon,
                        ),
                  onTap: () => const DownloadQueueRoute().push(context),
                ),
                _AppBarButton(
                  icon: const Icon(
                    LucideIcons.settings,
                    size: LayoutConstants.smallIcon,
                  ),
                  onTap: () => const SettingsRoute().push(context),
                ),
              ],
            ),
            if (loggedIn) const SliverLibraries(),
            const SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _AppBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: LayoutConstants.smallEdgeInsets,
        child: icon,
      ),
    );
  }
}
