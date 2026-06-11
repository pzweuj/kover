import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/utils/layout_constants.dart';

class CoverCard extends ConsumerWidget {
  final String? title;
  final Icon? icon;
  final double progress;
  final Widget coverImage;
  final Widget? downloadStatusIcon;
  final void Function()? onTap;

  const CoverCard({
    super.key,
    this.title,
    this.icon,
    required this.coverImage,
    this.downloadStatusIcon,
    this.onTap,
    double? progress,
  }) : progress = progress ?? 0.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card.filled(
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: coverImage),
                  if (progress <= 0)
                    Align(
                      alignment: .topRight,
                      child: Transform.translate(
                        offset: const Offset(20, -20),
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 40,
                            height: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  if (downloadStatusIcon != null)
                    Align(
                      alignment: .topLeft,
                      child: Padding(
                        padding: LayoutConstants.smallEdgeInsets,
                        child: downloadStatusIcon,
                      ),
                    ),
                ],
              ),
            ),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
            if (title != null)
              Padding(
                padding: LayoutConstants.smallEdgeInsets,
                child: Row(
                  mainAxisSize: .min,
                  spacing: LayoutConstants.smallPadding,
                  children: [
                    ?icon,
                    Expanded(
                      child: Text(title!, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
