import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/models/read_direction.dart';
import 'package:kover/riverpod/providers/breakpoints.dart';
import 'package:kover/riverpod/providers/settings/image_reader_settings.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/settings/boolean_option.dart';
import 'package:kover/widgets/settings/choice_option.dart';
import 'package:kover/widgets/settings/numeric_option.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImageReaderSettingsBottomSheet extends ConsumerWidget {
  final int seriesId;

  const ImageReaderSettingsBottomSheet({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = imageReaderSettingsProvider(seriesId: seriesId);
    final breakpoint = ref.watch(breakpointsProvider);
    return Async(
      asyncValue: ref.watch(provider),
      data: (settings) {
        return Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: LayoutConstants.largePadding,
                    right: LayoutConstants.largePadding,
                    bottom: LayoutConstants.largePadding,
                  ),
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    spacing: LayoutConstants.largePadding,
                    children: [
                      Text(
                        context.l10n.readerSettings,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ChoiceOption<ReadDirection>(
                        title: context.l10n.readingDirection,
                        icon: settings.readDirection == .leftToRight
                            ? LucideIcons.chevronsRight
                            : LucideIcons.chevronsLeft,
                        options: [
                          ChoiceOptionEntry(
                            value: .leftToRight,
                            label: context.l10n.leftToRight,
                            icon: LucideIcons.chevronsRight,
                          ),
                          ChoiceOptionEntry(
                            value: .rightToLeft,
                            label: context.l10n.rightToLeft,
                            icon: LucideIcons.chevronsLeft,
                          ),
                        ],
                        value: settings.readDirection,
                        onChanged: (newValue) async {
                          await ref
                              .read(provider.notifier)
                              .setReadDirection(newValue);
                        },
                      ),
                      ChoiceOption<ReaderMode>(
                        title: context.l10n.readerMode,
                        icon: switch (settings.readerMode) {
                          .horizontal => LucideIcons.moveHorizontal,
                          .vertical => LucideIcons.moveVertical,
                          .spread => LucideIcons.columns2,
                        },
                        options: [
                          ChoiceOptionEntry(
                            value: .horizontal,
                            label: context.l10n.horizontal,
                            icon: LucideIcons.moveHorizontal,
                          ),
                          ChoiceOptionEntry(
                            value: .vertical,
                            label: context.l10n.vertical,
                            icon: LucideIcons.moveVertical,
                          ),
                          if (breakpoint != .compact)
                            ChoiceOptionEntry(
                              value: .spread,
                              label: context.l10n.twoPage,
                              icon: LucideIcons.columns2,
                            ),
                        ],
                        value: settings.readerMode,
                        onChanged: (newValue) async {
                          await ref
                              .read(provider.notifier)
                              .setReaderMode(newValue);
                        },
                      ),
                      if (settings.readerMode == .horizontal) ...[
                        ChoiceOption<ImageScaleType>(
                          title: context.l10n.fitDirection,
                          icon: switch (settings.scaleType) {
                            .fitWidth => KoverIcons.fitWidth,
                            .fitHeight => KoverIcons.fitHeight,
                            .contain => KoverIcons.fitContain,
                          },
                          options: [
                            ChoiceOptionEntry(
                              value: .contain,
                              label: context.l10n.contain,
                              icon: KoverIcons.fitContain,
                            ),
                            ChoiceOptionEntry(
                              value: .fitWidth,
                              label: context.l10n.width,
                              icon: KoverIcons.fitWidth,
                            ),
                            ChoiceOptionEntry(
                              value: .fitHeight,
                              label: context.l10n.height,
                              icon: KoverIcons.fitHeight,
                            ),
                          ],
                          value: settings.scaleType,
                          onChanged: (newValue) async {
                            if (newValue != settings.scaleType) {
                              await ref
                                  .read(provider.notifier)
                                  .setScaleType(newValue);
                            }
                          },
                        ),
                      ],
                      if (settings.readerMode == .vertical) ...[
                        NumericOption(
                          title: context.l10n.margins,
                          icon: LucideIcons.panelLeftDashed,
                          value: settings.verticalReaderPadding,
                          min: ImageReaderSettingsLimits
                              .verticalReaderPaddingMin,
                          max: ImageReaderSettingsLimits
                              .verticalReaderPaddingMax,
                          step: ImageReaderSettingsLimits
                              .verticalReaderPaddingStep,
                          onChanged: (newValue) async => await ref
                              .read(provider.notifier)
                              .setVerticalReaderPadding(newValue),
                        ),
                        NumericOption(
                          title: context.l10n.verticalGap,
                          icon: LucideIcons.unfoldVertical,
                          value: settings.verticalReaderGap,
                          min: ImageReaderSettingsLimits.verticalReaderGapMin,
                          max: ImageReaderSettingsLimits.verticalReaderGapMax,
                          step: ImageReaderSettingsLimits.verticalReaderGapStep,
                          onChanged: (newValue) async => await ref
                              .read(provider.notifier)
                              .setVerticalReaderGap(newValue),
                        ),
                      ],
                      if (settings.readerMode == .spread) ...[
                        NumericOption(
                          title: context.l10n.pageGap,
                          icon: LucideIcons.unfoldHorizontal,
                          value: settings.spreadReaderGap,
                          min: ImageReaderSettingsLimits.spreadReaderGapMin,
                          max: ImageReaderSettingsLimits.spreadReaderGapMax,
                          step: ImageReaderSettingsLimits.spreadReaderGapStep,
                          decimalPlaces: 0,
                          onChanged: (newValue) async => await ref
                              .read(provider.notifier)
                              .setSpreadReaderGap(newValue),
                        ),
                        BooleanOption(
                          title: context.l10n.coverPage,
                          description: context.l10n.coverPageDescription,
                          icon: LucideIcons.bookImage,
                          value: settings.spreadCoverPage,
                          onChanged: (newValue) async => await ref
                              .read(provider.notifier)
                              .setSpreadCoverPage(newValue),
                        ),
                      ],
                      BooleanOption(
                        title: context.l10n.ignoreSafeAreas,
                        icon: KoverIcons.safeArea,
                        value: settings.ignoreSafeAreas,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setIgnoreSafeAreas(newValue),
                      ),
                      BooleanOption(
                        title: context.l10n.showProgressBar,
                        icon: KoverIcons.progressBar,
                        value: settings.showProgressBar,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setShowProgressBar(newValue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: LayoutConstants.largePadding,
                right: LayoutConstants.largePadding,
                bottom: LayoutConstants.largePadding,
                top: LayoutConstants.mediumPadding,
              ),
              child: Row(
                spacing: LayoutConstants.mediumPadding,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () async =>
                          await ref.read(provider.notifier).setDefault(),
                      icon: const Icon(LucideIcons.save),
                      label: Text(context.l10n.setDefaults),
                    ),
                  ),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () async =>
                          await ref.read(provider.notifier).reset(),
                      icon: const Icon(LucideIcons.rotateCcw),
                      label: Text(context.l10n.reset),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
