import 'package:html/dom.dart';
import 'package:kover/utils/html_constants.dart';

extension DocumentFragmentExtensions on DocumentFragment {
  String? paragraphScrollId() {
    final p = querySelector('p');

    return p?.attributes[HtmlConstants.scrollIdAttribute];
  }
}

extension NodeExtensions on Node {
  bool get hasVisibleNodes {
    return isTextOrImage || nodes.any((node) => node.hasVisibleNodes);
  }

  bool get isTextOrImage {
    return (this is Text && text != null && text!.trim().isNotEmpty) ||
        (this is Element &&
            _imageTags.contains(
              (this as Element).localName,
            ));
  }

  static const _imageTags = {'img', 'svg'};
}
