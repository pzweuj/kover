import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/models/volume_model.dart';
import 'package:kover/pages/series_detail_page/series_app_bar.dart';
import 'package:kover/riverpod/providers/reader.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/details/summary.dart';
import 'package:kover/widgets/lists/inline_chapters_grid.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';

class SeriesDetailPage extends HookConsumerWidget {
  final int seriesId;

  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(seriesDetailProvider(seriesId: seriesId));
    final summary = ref.watch(
      seriesMetadataProvider(seriesId: seriesId).select(
        (value) => value.asData?.value.summary,
      ),
    );
    final continuePoint = ref.watch(
      continuePointStreamProvider(seriesId: seriesId),
    );

    // Track which volumes are expanded
    final expandedVolumes = useState<Set<int>>({});
    final hasAutoExpanded = useRef(false);

    // Auto-expand the volume containing the current reading chapter
    useEffect(() {
      final volumeId = continuePoint.value?.volumeId;
      if (volumeId != null && !hasAutoExpanded.value) {
        expandedVolumes.value = {volumeId};
        hasAutoExpanded.value = true;
      }
      return null;
    }, [continuePoint.value?.volumeId]);

    return Scaffold(
      body: Async(
        asyncValue: details,
        data: (detailsData) {
          return CustomScrollView(
            slivers: [
              SeriesAppBar(seriesId: seriesId),
              SliverPadding(
                padding: const EdgeInsetsGeometry.only(
                  top: LayoutConstants.mediumPadding,
                  left: LayoutConstants.mediumPadding,
                  right: LayoutConstants.mediumPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    spacing: LayoutConstants.smallPadding,
                    crossAxisAlignment: .start,
                    children: [
                      if (detailsData.specials.isNotEmpty)
                        _InlineSection(
                          title: context.l10n.countLabel(
                            context.l10n.specials,
                            detailsData.specials.length,
                          ),
                          child: InlineChaptersGrid(
                            seriesId: seriesId,
                            chapters: detailsData.specials,
                          ),
                        ),
                      if (detailsData.storyline.isNotEmpty)
                        _InlineSection(
                          title: context.l10n.countLabel(
                            context.l10n.storyline,
                            detailsData.storyline.length,
                          ),
                          child: InlineChaptersGrid(
                            seriesId: seriesId,
                            chapters: detailsData.storyline,
                          ),
                        ),
                      if (detailsData.volumes.isNotEmpty)
                        _VolumesAccordion(
                          seriesId: seriesId,
                          volumes: detailsData.volumes,
                          expandedVolumes: expandedVolumes,
                        ),
                      if (detailsData.chapters.isNotEmpty)
                        _InlineSection(
                          title: context.l10n.countLabel(
                            context.l10n.chapters,
                            detailsData.chapters.length,
                          ),
                          child: InlineChaptersGrid(
                            seriesId: seriesId,
                            chapters: detailsData.chapters,
                          ),
                        ),
                      Summary(summary: summary),
                      _Genres(seriesId: seriesId),
                    ],
                  ),
                ),
              ),
              const SliverBottomPadding(),
            ],
          );
        },
        loading: () => CustomScrollView(
          slivers: [
            SeriesAppBar(
              seriesId: seriesId,
            ),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card-wrapped section with a title header and inline child content.
class _InlineSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InlineSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: .antiAlias,
      child: Padding(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Column(
          crossAxisAlignment: .start,
          spacing: LayoutConstants.smallPadding,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Accordion-style volume list with expandable chapter grids.
class _VolumesAccordion extends StatelessWidget {
  final int seriesId;
  final List<VolumeModel> volumes;
  final ValueNotifier<Set<int>> expandedVolumes;

  const _VolumesAccordion({
    required this.seriesId,
    required this.volumes,
    required this.expandedVolumes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card.filled(
      clipBehavior: .antiAlias,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: LayoutConstants.mediumEdgeInsets,
            child: Text(
              l10n.countLabel(l10n.volumes, volumes.length),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ...volumes.map(
            (volume) => _VolumeExpansionTile(
              seriesId: seriesId,
              volume: volume,
              isExpanded: expandedVolumes.value.contains(volume.id),
              onExpansionChanged: (expanded) {
                final current = Set<int>.from(expandedVolumes.value);
                if (expanded) {
                  current.add(volume.id);
                } else {
                  current.remove(volume.id);
                }
                expandedVolumes.value = current;
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A single expandable volume tile that reveals its chapter grid.
class _VolumeExpansionTile extends StatelessWidget {
  final int seriesId;
  final VolumeModel volume;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const _VolumeExpansionTile({
    required this.seriesId,
    required this.volume,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey('volume-${volume.id}'),
      initiallyExpanded: isExpanded,
      maintainState: false,
      onExpansionChanged: onExpansionChanged,
      tilePadding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.mediumPadding,
      ),
      childrenPadding: LayoutConstants.smallerEdgeInsets,
      title: Text(
        volume.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        context.l10n.countLabel(
          context.l10n.chapters,
          volume.chapters.length,
        ),
      ),
      children: [
        InlineChaptersGrid(
          seriesId: seriesId,
          chapters: volume.chapters,
        ),
      ],
    );
  }
}

class _Genres extends ConsumerWidget {
  final int seriesId;
  const _Genres({
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(seriesMetadataProvider(seriesId: seriesId));
    final theme = Theme.of(context);
    return Async(
      asyncValue: metadata,
      data: (metadata) => Column(
        crossAxisAlignment: .start,
        spacing: LayoutConstants.smallPadding,
        children: [
          Text(
            context.l10n.genres,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Wrap(
            spacing: LayoutConstants.mediumPadding,
            runSpacing: LayoutConstants.mediumPadding,
            alignment: .start,
            children: metadata.genres
                .map(
                  (g) => Chip(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    label: Text(
                      g.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
