import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/riverpod/providers/want_to_read.dart';
import 'package:kover/utils/extensions/int.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WantToReadToggle extends ConsumerWidget {
  final int seriesId;
  const WantToReadToggle({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wantToRead = ref.watch(wantToReadProvider(seriesId: seriesId));

    return Async(
      asyncValue: wantToRead,
      data: (data) {
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              data ? Icons.star : LucideIcons.star,
              key: ValueKey(data),
            ),
          ),
          color: data ? Theme.of(context).colorScheme.primary : null,
          onPressed: () async {
            final notifier = ref.read(
              wantToReadProvider(seriesId: seriesId).notifier,
            );
            await (data ? notifier.remove() : notifier.add());
          },
        );
      },
    );
  }
}

class WordCount extends StatelessWidget {
  final int wordCount;

  const WordCount({
    super.key,
    required this.wordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        const Icon(
          LucideIcons.fileText,
          size: LayoutConstants.smallIcon,
        ),
        Text(
          context.l10n.wordCount(wordCount.prettyInt()),
        ),
      ],
    );
  }
}

class RemainingHours extends StatelessWidget {
  final double hours;

  const RemainingHours({
    super.key,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        const Icon(
          LucideIcons.clock,
          size: LayoutConstants.smallIcon,
        ),
        Text(
          context.l10n.remainingHours(hours.toStringAsFixed(1)),
        ),
      ],
    );
  }
}

class Pages extends StatelessWidget {
  final int pages;
  const Pages({
    super.key,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: LayoutConstants.smallPadding,
      children: [
        const Icon(
          LucideIcons.fileStack,
          size: LayoutConstants.smallIcon,
        ),
        Text(context.l10n.pages(pages.prettyInt())),
      ],
    );
  }
}
