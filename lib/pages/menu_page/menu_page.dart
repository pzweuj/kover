import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/pages/menu_page/app_list_tile.dart';
import 'package:kover/pages/menu_page/sliver_libraries.dart';
import 'package:kover/pages/menu_page/sliver_section.dart';
import 'package:kover/riverpod/managers/download_manager.dart';
import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:kover/riverpod/providers/auth.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/utils/constants/kover_icons.dart';
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
            const ActionsAppBar(),
            if (loggedIn) ...[
              _menuTile(
                context,
                title: l10n.allSeries,
                icon: const Icon(LucideIcons.list),
                onTap: () => const AllSeriesRoute().push(context),
              ),
              _menuTile(
                context,
                title: l10n.collections,
                icon: const Icon(KoverIcons.collection),
                onTap: () => const CollectionsRoute().push(context),
              ),
              _menuTile(
                context,
                title: l10n.readingLists,
                icon: const Icon(KoverIcons.readingList),
                onTap: () => const ReadingListsRoute().push(context),
              ),
              SliverSection(title: l10n.libraries),
              const SliverLibraries(),
            ],
            SliverSection(title: l10n.more),
            _menuTile(
              context,
              title: l10n.downloadQueue,
              icon: isDownloading
                  ? const Icon(LucideIcons.refreshCw)
                        .animate(onPlay: (c) => c.repeat())
                        .rotate(duration: 1500.ms)
                  : const Icon(LucideIcons.download),
              onTap: () => const DownloadQueueRoute().push(context),
            ),
            _menuTile(
              context,
              title: l10n.settings,
              icon: const Icon(LucideIcons.settings),
              onTap: () => const SettingsRoute().push(context),
            ),
            const SliverBottomPadding(),
          ],
        ),
      ),
    );
  }

  SliverPadding _menuTile(
    BuildContext context, {
    required String title,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: LayoutConstants.smallerPadding,
        horizontal: LayoutConstants.mediumPadding,
      ),
      sliver: SliverToBoxAdapter(
        child: AppListTile(title: title, icon: icon, onTap: onTap),
      ),
    );
  }
}
