import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/utils/layout_constants.dart';

class AdaptiveSliverAppBar extends HookConsumerWidget {
  final PreferredSizeWidget? bottom;
  final Widget title;
  final Widget? background;
  final List<Widget>? actions;
  final Widget child;

  const AdaptiveSliverAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.background,
    this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final isCollapsed = useState(false);

    final minFlexibleHeight =
        kToolbarHeight + topPadding + (bottom?.preferredSize.height ?? 0.0);

    final expandedHeight = (screenHeight * 0.4)
        .clamp(minFlexibleHeight + 200.0, screenHeight * 0.5)
        .toDouble();

    return SliverAppBar(
      title: isCollapsed.value
          ? title.animate(target: isCollapsed.value ? 1 : 0).fade()
          : null,
      pinned: true,
      expandedHeight: expandedHeight,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.smallPadding,
      ),
      actions: actions,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final flexibleRange = (expandedHeight - minFlexibleHeight)
              .clamp(1.0, double.infinity)
              .toDouble();
          final value =
              (constraints.maxHeight - minFlexibleHeight) / flexibleRange;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            isCollapsed.value = constraints.maxHeight <= minFlexibleHeight;
          });

          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (background != null) Positioned.fill(child: background!),
                  SafeArea(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          );
        },
      ),
      bottom: bottom,
    );
  }
}
