import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:kover/riverpod/providers/want_to_read.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/actions_app_bar/actions_app_bar.dart';
import 'package:kover/widgets/lists/series_sliver_grid.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';

class WantToReadPage extends HookConsumerWidget {
  const WantToReadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.read(syncManagerProvider.notifier).syncLibraries();
      return null;
    }, const []);

    return Scaffold(
      extendBody: true,
      body: LoginGuard(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => await ref.refresh(wantToReadListProvider),
            child: CustomScrollView(
              slivers: [
                ActionsAppBar(title: context.l10n.wantToRead),
                const WantToReadGrid(),
                const SliverBottomPadding(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WantToReadGrid extends ConsumerWidget {
  const WantToReadGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(wantToReadListProvider);
    return AsyncSliver(
      asyncValue: series,
      data: (data) => SliverPadding(
        padding: LayoutConstants.smallEdgeInsets,
        sliver: SeriesSliverGrid(series: data),
      ),
    );
  }
}
