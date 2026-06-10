import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kover/utils/layout_constants.dart';

class OptionContainer extends StatelessWidget {
  final String title;
  final String? description;
  final String? value;
  final IconData? icon;
  final bool sameRow;
  final Widget child;

  const OptionContainer({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.value,
    this.icon,
    this.sameRow = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSameRow = sameRow && constraints.maxWidth >= 420;

        return Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          spacing: LayoutConstants.smallPadding,
          children: [
            Row(
              spacing: LayoutConstants.smallPadding,
              children: [
                Expanded(child: _OptionTitle(icon: icon, title: title)),
                if (description != null)
                  Tooltip(
                    message: description!,
                    triggerMode: .tap,
                    showDuration: 60.minutes,
                    margin: const EdgeInsets.symmetric(
                      horizontal: LayoutConstants.largePadding,
                    ),
                    child: const IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: null,
                    ),
                  ),
                if (useSameRow) child,
                if (value != null)
                  Text(
                    value!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
            if (!useSameRow)
              SizedBox(width: double.infinity, child: child),
          ],
        );
      },
    );
  }
}

class _OptionTitle extends StatelessWidget {
  final IconData? icon;
  final String title;

  const _OptionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: LayoutConstants.smallPadding,
      children: [
        if (icon != null) Icon(icon),
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
