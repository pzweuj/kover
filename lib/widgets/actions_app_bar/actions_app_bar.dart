import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/actions_app_bar/search_button.dart';
import 'package:kover/widgets/actions_app_bar/sync_button.dart';

class ActionsAppBar extends StatelessWidget {
  final String? title;
  final List<Widget> leadingActions;

  const ActionsAppBar({
    super.key,
    this.title,
    this.leadingActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      actionsPadding: LayoutConstants.smallEdgeInsets,
      title: title != null
          ? Text(
              title!,
              style: Theme.of(context).textTheme.headlineMedium,
            )
          : null,
      actions: [
        _ActionsBar(leadingActions: leadingActions),
      ],
    );
  }
}

class _ActionsBar extends ConsumerWidget {
  final List<Widget> leadingActions;

  const _ActionsBar({required this.leadingActions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shape = theme.cardTheme.shape as RoundedRectangleBorder?;
    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      shape: shape?.copyWith(
        borderRadius: const BorderRadiusGeometry.all(
          Radius.circular(LayoutConstants.mediumBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: LayoutConstants.smallerPadding,
          horizontal: LayoutConstants.smallPadding,
        ),
        child: Row(
          spacing: LayoutConstants.smallPadding,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...leadingActions,
            if (leadingActions.isNotEmpty)
              Container(
                width: 1,
                height: LayoutConstants.mediumIcon,
                color: theme.colorScheme.outlineVariant,
              ),
            const SearchButton(),
            const SyncButton(),
          ],
        ),
      ),
    );
  }
}
