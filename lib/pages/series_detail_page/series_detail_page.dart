import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/pages/series_detail_page/series_app_bar.dart';
import 'package:kover/riverpod/providers/reader.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/extensions/int.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/details/summary.dart';
import 'package:kover/widgets/lists/inline_chapters_grid.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesDetailPage extends ConsumerWidget {
  final int seriesId;

  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(seriesDetailProvider(seriesId: seriesId));
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final metadata = ref.watch(seriesMetadataProvider(seriesId: seriesId));
    final progress = ref.watch(seriesProgressProvider(seriesId: seriesId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Async(
        asyncValue: details,
        data: (detailsData) {
          return CustomScrollView(
            slivers: [
              SeriesAppBar(seriesId: seriesId),

              // -- Body content --
              SliverToBoxAdapter(
                child: Async(
                  asyncValue: series,
                  data: (seriesData) => _DetailBody(
                    seriesId: seriesId,
                    series: seriesData,
                    details: detailsData,
                    metadata: metadata,
                    progress: progress.value,
                  ),
                ),
              ),

              const SliverBottomPadding(),
            ],
          );
        },
        loading: () => CustomScrollView(
          slivers: [
            SeriesAppBar(seriesId: seriesId),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail Body — unified, modern layout
// ---------------------------------------------------------------------------
class _DetailBody extends ConsumerWidget {
  final int seriesId;
  final SeriesModel series;
  final SeriesDetailModel details;
  final AsyncValue<SeriesMetadataModel> metadata;
  final double? progress;

  const _DetailBody({
    required this.seriesId,
    required this.series,
    required this.details,
    required this.metadata,
    required this.progress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = screenWidth < 400 ? 12.0 : LayoutConstants.mediumPadding;
    final isCompact = screenWidth < 380;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: LayoutConstants.mediumPadding),

          // ── Title ──
          Text(
            series.name,
            style: (isCompact
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall)
                ?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: LayoutConstants.smallPadding),

          // ── Metadata row ──
          Async(
            asyncValue: metadata,
            data: (meta) => _MetadataRow(series: series, metadata: meta),
          ),

          const SizedBox(height: LayoutConstants.mediumPadding),

          // ── Continue Reading CTA ──
          _ContinueReadingCard(seriesId: seriesId, progress: progress),

          const SizedBox(height: LayoutConstants.mediumPadding),

          // ── Progress bar ──
          if (progress != null && progress! > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: LayoutConstants.smallPadding),
            Text(
              '${(progress! * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: LayoutConstants.mediumPadding),
          ],

          // ── Summary ──
          Async(
            asyncValue: metadata,
            data: (meta) {
              if (meta.summary?.isEmpty ?? true) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: LayoutConstants.mediumPadding,
                ),
                child: Summary(summary: meta.summary),
              );
            },
          ),

          // ── Content sections ──
          if (details.specials.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.countLabel(l10n.specials, details.specials.length),
            ),
            InlineChaptersGrid(
              seriesId: seriesId,
              chapters: details.specials,
            ),
            const SizedBox(height: LayoutConstants.mediumPadding),
          ],

          if (details.storyline.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.countLabel(l10n.storyline, details.storyline.length),
            ),
            InlineChaptersGrid(
              seriesId: seriesId,
              chapters: details.storyline,
            ),
            const SizedBox(height: LayoutConstants.mediumPadding),
          ],

          if (details.volumes.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.countLabel(
                l10n.volumes,
                details.volumes.fold(
                  0,
                  (sum, v) => sum + v.chapters.length,
                ),
              ),
            ),
            InlineChaptersGrid(
              seriesId: seriesId,
              chapters: details.volumes
                  .expand((v) => v.chapters)
                  .toList(),
            ),
            const SizedBox(height: LayoutConstants.mediumPadding),
          ],

          if (details.chapters.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.countLabel(l10n.chapters, details.chapters.length),
            ),
            InlineChaptersGrid(
              seriesId: seriesId,
              chapters: details.chapters,
            ),
            const SizedBox(height: LayoutConstants.mediumPadding),
          ],

          // ── Genres ──
          _GenresSection(seriesId: seriesId),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata Row — compact inline info chips
// ---------------------------------------------------------------------------
class _MetadataRow extends StatelessWidget {
  final SeriesModel series;
  final SeriesMetadataModel metadata;

  const _MetadataRow({required this.series, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (metadata.writers.isNotEmpty) {
      chips.add(
        _InfoChip(
          icon: LucideIcons.penLine,
          label: metadata.writers.map((w) => w.name).join(', '),
        ),
      );
    }
    if (metadata.releaseYear != null) {
      chips.add(
        _InfoChip(
          icon: LucideIcons.calendar,
          label: metadata.releaseYear.toString(),
        ),
      );
    }
    chips.add(
      _InfoChip(
        icon: LucideIcons.fileStack,
        label: context.l10n.pages(series.pages.prettyInt()),
      ),
    );
    if ((series.wordCount ?? 0) > 0) {
      chips.add(
        _InfoChip(
          icon: LucideIcons.fileText,
          label: context.l10n.wordCount(series.wordCount!.prettyInt()),
        ),
      );
    }
    if (series.avgHoursToRead > 0) {
      chips.add(
        _InfoChip(
          icon: LucideIcons.clock,
          label: context.l10n.remainingHours(
            series.avgHoursToRead.toStringAsFixed(1),
          ),
        ),
      );
    }

    return Wrap(
      spacing: LayoutConstants.smallPadding,
      runSpacing: LayoutConstants.smallerPadding,
      children: chips,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Continue Reading Card
// ---------------------------------------------------------------------------
class _ContinueReadingCard extends ConsumerWidget {
  final int seriesId;
  final double? progress;

  const _ContinueReadingCard({required this.seriesId, this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final continuePoint = ref.watch(continuePointProvider(seriesId: seriesId));

    return Async(
      asyncValue: continuePoint,
      data: (data) => Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.primaryContainer,
        clipBehavior: .antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LayoutConstants.mediumBorderRadius),
        ),
        child: InkWell(
          onTap: () => ReaderRoute(seriesId: seriesId).push(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LayoutConstants.mediumPadding,
              vertical: LayoutConstants.mediumPadding,
            ),
            child: Row(
              children: [
                // Play icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.play,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: LayoutConstants.mediumPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.continueReading,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (progress != null)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.2),
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LayoutConstants.smallPadding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Genres Section
// ---------------------------------------------------------------------------
class _GenresSection extends ConsumerWidget {
  final int seriesId;
  const _GenresSection({required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(seriesMetadataProvider(seriesId: seriesId));
    final theme = Theme.of(context);

    return Async(
      asyncValue: metadata,
      data: (metadata) {
        if (metadata.genres.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(
            bottom: LayoutConstants.mediumPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: LayoutConstants.smallPadding,
                ),
                child: Text(
                  context.l10n.genres,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Wrap(
                spacing: LayoutConstants.smallerPadding,
                runSpacing: LayoutConstants.smallerPadding,
                children: metadata.genres
                    .map(
                      (g) => Chip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      },
    );
  }
}
