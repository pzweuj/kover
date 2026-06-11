import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kover/models/epub_image_fit.dart';

class CachedImageFactory extends WidgetFactory {
  // final BuildContext context;
  final Map<int, MemoryImage> _cache = {};
  final EpubImageFit imageFit;

  CachedImageFactory({this.imageFit = EpubImageFit.fitWidth});

  @override
  Widget? buildImageWidget(BuildTree meta, ImageSource src) {
    final bytes = bytesFromDataUri(src.url);

    if (bytes == null) {
      return super.buildImageWidget(meta, src);
    }

    final hash = src.url.hashCode;

    final provider = _cache[hash] ??= MemoryImage(bytes);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.sizeOf(context);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : size.width;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : size.height - MediaQuery.paddingOf(context).vertical;

        return switch (imageFit) {
          EpubImageFit.original => Center(
            child: Image(
              key: ValueKey(hash),
              image: provider,
              gaplessPlayback: true,
              fit: BoxFit.contain,
            ),
          ),
          EpubImageFit.fitWidth => Center(
            child: Image(
              key: ValueKey(hash),
              image: provider,
              width: availableWidth,
              gaplessPlayback: true,
              fit: BoxFit.fitWidth,
            ),
          ),
          EpubImageFit.fitHeight => Center(
            child: Image(
              key: ValueKey(hash),
              image: provider,
              height: availableHeight,
              gaplessPlayback: true,
              fit: BoxFit.fitHeight,
            ),
          ),
          EpubImageFit.contain => SizedBox(
            width: availableWidth,
            height: availableHeight,
            child: Image(
              key: ValueKey(hash),
              image: provider,
              gaplessPlayback: true,
              fit: BoxFit.contain,
            ),
          ),
          EpubImageFit.stretch => SizedBox(
            width: availableWidth,
            height: availableHeight,
            child: Image(
              key: ValueKey(hash),
              image: provider,
              gaplessPlayback: true,
              fit: BoxFit.fill,
            ),
          ),
        };
      },
    );
  }
}
