import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/managers/download_manager.dart';
import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:kover/riverpod/providers/download.dart';
import 'package:kover/riverpod/providers/reader.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/context_menu/actions_menu.dart';
import 'package:kover/widgets/details/info_widgets.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A modern, clean hero section for the series detail page.
/// Shows the cover image with a gradient overlay, floating navigation
/// and action buttons.
class SeriesAppBar extends HookConsumerWidget {
  final int seriesId;

  const SeriesAppBar({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final downloadProgress =
        ref.watch(seriesDownloadProgressProvider(seriesId: seriesId)).value ??
        0.0;

    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final screenWidth = MediaQuery.sizeOf(context).width;
        // Adaptive height: smaller ratio on small screens, larger on tablets
        final expandedHeight = screenWidth < 400
            ? (screenHeight * 0.35).clamp(260.0, 360.0)
            : (screenHeight * 0.42).clamp(300.0, screenHeight * 0.52);

        return SliverAppBar(
          pinned: true,
          expandedHeight: expandedHeight,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight,
          leadingWidth: 56,
          leading: _FloatingCircleButton(
            onTap: () => context.pop(),
            child: const Icon(LucideIcons.arrowLeft, size: 20),
          ),
          actions: [
            WantToReadToggle(seriesId: data.id),
            ActionsMenuButton(
              onMarkRead: () async {
                await ref
                    .read(markSeriesReadProvider(seriesId: seriesId).notifier)
                    .markRead();
              },
              onMarkUnread: () async {
                await ref
                    .read(markSeriesReadProvider(seriesId: seriesId).notifier)
                    .markUnread();
              },
              onDownload: downloadProgress < 1.0
                  ? () async {
                      await ref
                          .read(downloadManagerProvider.notifier)
                          .enqueueSeries(seriesId);
                    }
                  : null,
              onRemoveDownload: downloadProgress > 0.0
                  ? () async {
                      await ref
                          .read(downloadManagerProvider.notifier)
                          .deleteSeries(seriesId);
                    }
                  : null,
              onRefreshMetadata: () {
                ref
                    .read(syncManagerProvider.notifier)
                    .refreshMetadataAndDetails(seriesId: seriesId);
              },
              onRefreshCovers: () {
                ref
                    .read(syncManagerProvider.notifier)
                    .refreshCovers(seriesId: seriesId);
              },
              child: const Icon(LucideIcons.ellipsisVertical),
            ),
          ],
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final isCollapsed =
                  constraints.maxHeight < expandedHeight - 60;

              return FlexibleSpaceBar(
                title: isCollapsed
                    ? Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
                centerTitle: false,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover image as background
                    Positioned.fill(
                      child: SeriesCoverImage(
                        seriesId: seriesId,
                        usePlaceholder: true,
                        fit: BoxFit.cover,
                        heroTag: 'series-cover-$seriesId',
                      ),
                    ),
                    // Gradient overlay for readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.0, 0.25, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Top scrim for button readability
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: kToolbarHeight +
                            MediaQuery.paddingOf(context).top,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A floating circular button with a blurred background,
/// used for back navigation and other floating actions.
class _FloatingCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _FloatingCircleButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LayoutConstants.smallPadding),
      child: Material(
        color: Colors.black26,
        shape: const CircleBorder(),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 40,
            child: Center(child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 20),
              child: child,
            )),
          ),
        ),
      ),
    );
  }
}
