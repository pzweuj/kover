import 'package:flutter/material.dart';
import 'package:kover/models/chapter_model.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/cards/chapter_card.dart';

/// Non-sliver version of [AdaptiveSliverGrid] + [ChaptersGrid] for use
/// inside [ExpansionTile.children], [Column], or other non-sliver parents.
class InlineChaptersGrid extends StatelessWidget {
  final int seriesId;
  final List<ChapterModel> chapters;

  const InlineChaptersGrid({
    super.key,
    required this.seriesId,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          final w when w >= LayoutBreakpoints.large => 12,
          final w when w >= LayoutBreakpoints.expanded => 10,
          final w when w >= LayoutBreakpoints.medium => 7,
          final w when w >= LayoutBreakpoints.compact => 5,
          final w when w >= 360 => 4,
          _ => 3,
        };

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: LayoutConstants.chapterCardAspectRatio,
            mainAxisSpacing: LayoutConstants.smallerPadding,
            crossAxisSpacing: LayoutConstants.smallerPadding,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ChapterCard(chapterId: chapter.id, seriesId: seriesId);
          },
        );
      },
    );
  }
}
