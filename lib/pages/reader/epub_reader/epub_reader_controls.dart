import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/l10n/app_localizations.dart';
import 'package:kover/models/epub_image_fit.dart';
import 'package:kover/models/read_direction.dart';
import 'package:kover/riverpod/providers/settings/epub_reader_settings.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/settings/boolean_option.dart';
import 'package:kover/widgets/settings/choice_option.dart';
import 'package:kover/widgets/settings/numeric_option.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EpubReaderSettingsBottomSheet extends ConsumerWidget {
  final int seriesId;
  const EpubReaderSettingsBottomSheet({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = epubReaderSettingsProvider(seriesId: seriesId);

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
                    crossAxisAlignment: .start,
                    spacing: LayoutConstants.largePadding,
                    children: [
                      Text(
                        context.l10n.readerSettings,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ChoiceOption(
                        title: context.l10n.readingDirection,
                        icon: settings.readDirection == .leftToRight
                            ? LucideIcons.chevronsRight
                            : LucideIcons.chevronsLeft,
                        value: settings.readDirection,
                        options: [
                          ChoiceOptionEntry<ReadDirection>(
                            value: ReadDirection.leftToRight,
                            label: context.l10n.leftToRight,
                            icon: LucideIcons.chevronsRight,
                          ),
                          ChoiceOptionEntry<ReadDirection>(
                            value: ReadDirection.rightToLeft,
                            label: context.l10n.rightToLeft,
                            icon: LucideIcons.chevronsLeft,
                          ),
                        ],
                        onChanged: (newValue) async {
                          if (newValue != settings.readDirection) {
                            await ref
                                .read(provider.notifier)
                                .toggleReadDirection();
                          }
                        },
                      ),
                      ChoiceOption<EpubImageFit>(
                        title: context.l10n.imageFit,
                        icon: LucideIcons.image,
                        value: settings.imageFit,
                        options: [
                          ChoiceOptionEntry(
                            value: EpubImageFit.original,
                            label: context.l10n.originalSize,
                            icon: LucideIcons.image,
                          ),
                          ChoiceOptionEntry(
                            value: EpubImageFit.fitWidth,
                            label: context.l10n.width,
                            icon: KoverIcons.fitWidth,
                          ),
                          ChoiceOptionEntry(
                            value: EpubImageFit.fitHeight,
                            label: context.l10n.height,
                            icon: KoverIcons.fitHeight,
                          ),
                          ChoiceOptionEntry(
                            value: EpubImageFit.contain,
                            label: context.l10n.contain,
                            icon: KoverIcons.fitContain,
                          ),
                          ChoiceOptionEntry(
                            value: EpubImageFit.stretch,
                            label: context.l10n.stretch,
                            icon: Icons.open_in_full,
                          ),
                        ],
                        onChanged: (newValue) async {
                          await ref
                              .read(provider.notifier)
                              .setImageFit(newValue);
                        },
                      ),
                      NumericOption(
                        title: context.l10n.fontSize,
                        icon: LucideIcons.aLargeSmallDir,
                        value: settings.fontSize,
                        min: EpubReaderSettingsLimits.fontSizeMin,
                        max: EpubReaderSettingsLimits.fontSizeMax,
                        step: EpubReaderSettingsLimits.fontSizeStep,
                        decimalPlaces: 0,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setFontSize(newValue),
                      ),
                      NumericOption(
                        title: context.l10n.margins,
                        icon: LucideIcons.panelLeftDashed,
                        value: settings.marginSize,
                        min: EpubReaderSettingsLimits.marginSizeMin,
                        max: EpubReaderSettingsLimits.marginSizeMax,
                        step: EpubReaderSettingsLimits.marginSizeStep,
                        decimalPlaces: 0,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setMarginSize(newValue),
                      ),

                      NumericOption(
                        title: context.l10n.lineHeight,
                        icon: LucideIcons.listChevronsUpDown,
                        value: settings.lineHeight,
                        min: EpubReaderSettingsLimits.lineHeightMin,
                        max: EpubReaderSettingsLimits.lineHeightMax,
                        step: EpubReaderSettingsLimits.lineHeightStep,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setLineHeight(newValue),
                      ),
                      NumericOption(
                        value: settings.wordSpacing,
                        title: context.l10n.wordSpacing,
                        min: EpubReaderSettingsLimits.wordSpacingMin,
                        max: EpubReaderSettingsLimits.wordSpacingMax,
                        step: EpubReaderSettingsLimits.wordSpacingStep,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setWordSpacing(newValue),
                        icon: LucideIcons.listMinus,
                      ),
                      NumericOption(
                        title: context.l10n.letterSpacing,
                        icon: LucideIcons.wholeWord,
                        value: settings.letterSpacing,
                        min: EpubReaderSettingsLimits.letterSpacingMin,
                        max: EpubReaderSettingsLimits.letterSpacingMax,
                        step: EpubReaderSettingsLimits.letterSpacingStep,
                        onChanged: (newValue) async => await ref
                            .read(provider.notifier)
                            .setLetterSpacing(newValue),
                      ),
                      BooleanOption(
                        icon: LucideIcons.highlighter,
                        title: context.l10n.highlightResumeParagraph,
                        value: settings.highlightResumePoint,
                        onChanged: (value) async {
                          await ref
                              .read(provider.notifier)
                              .setHighlightResumePoint(value);
                        },
                      ),
                      BooleanOption(
                        icon: KoverIcons.progressBar,
                        title: context.l10n.showProgressBar,
                        value: settings.showProgressBar,
                        onChanged: (value) async {
                          await ref
                              .read(provider.notifier)
                              .setShowProgressBar(value);
                        },
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
