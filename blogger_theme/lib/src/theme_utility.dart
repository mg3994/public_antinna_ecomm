import 'core.dart';
import 'html_components.dart';

/// Builds a complete Blogger theme document from head and body components.
///
/// Use [generate] to render the theme as a full XML string with the required
/// Blogger template declaration.
class BloggerTheme extends Component {
  final Iterable<Component> head;
  final Iterable<Component> body;
  final Map<String, String>? attributes;

  const BloggerTheme({
    required this.head,
    required this.body,
    this.attributes,
  });
  @override
  Iterable<Component> build() {
    return [
      Html(
        attributesz: attributes,
        children: [
          Head(children: head),
          Body(children: body),
        ],
      ),
    ];
  }

  /// Renders this theme to a full Blogger-compatible XML document.
  String generate() {
    var renderer = Renderer();
    return '<?xml version="1.0" encoding="UTF-8" ?>\n'
        '${renderer.render(this)}';
  }
}
