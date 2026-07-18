import 'core.dart';

/// The root HTML element for a Blogger template.
///
/// Automatically merges the Blogger-required namespace and default template
/// attributes unless overridden by [attributesz].
class Html extends DomComponent {
  final Map<String, String?>? attributesz;

  static const Map<String, String> _defaultAttributes = {
    // if they are not specified we will default to these values for better compatibility
    // with Blogger's template requirements shown below, but they can be overridden if needed
    'b:css': 'false',
    'b:defaultwidgetversion': '2',
    'b:layoutsversion': '3',
    'b:responsive': 'true',
    'expr:dir': 'data:blog.languageDirection',
    'expr:lang': 'data:blog.locale',
    // below are the standard XML namespaces for Blogger templates and they are fixed
    'xmlns': 'http://www.w3.org/1999/xhtml',
    'xmlns:b': 'http://www.google.com/2005/gml/b',
    'xmlns:data': 'http://www.google.com/2005/gml/data',
    'xmlns:expr': 'http://www.google.com/2005/gml/expr',
  };

  Html({this.attributesz, super.children}) : super('html', attributes: _mergeAttributes(attributesz));

  static Map<String, String> _mergeAttributes(
    Map<String, String?>? attributes,
  ) {
    final merged = <String, String>{};
    if (attributes != null) {
      for (final entry in attributes.entries) {
        if (entry.value != null) {
          merged[entry.key] = entry.value!;
        }
      }
    }
    for (final entry in _defaultAttributes.entries) {
      merged.putIfAbsent(entry.key, () => entry.value);
    }
    return merged;
  }
}

/// The document head element.
class Head extends DomComponent {
  const Head({super.children}) : super('head');
}

/// The document body element.
class Body extends DomComponent {
  const Body({super.children}) : super('body');
}

/// A title element within the document head.
class Title extends DomComponent {
  const Title({super.children}) : super('title');
}

/// A metadata element that does not render children.
class Meta extends DomComponent {
  const Meta({super.attributes}) : super('meta');

  @override
  Iterable<Component> build() => [];
}

/// A link element that does not render children.
class Link extends DomComponent {
  const Link({super.attributes}) : super('link');

  @override
  Iterable<Component> build() => [];
}

/// A base URL element that does not render children.
class Base extends DomComponent {
  const Base({super.attributes}) : super('base');

  @override
  Iterable<Component> build() => [];
}

/// A generic div element.
class Div extends DomComponent {
  const Div({super.attributes, super.children}) : super('div');
}

/// A form element.
class Form extends DomComponent {
  const Form({super.attributes, super.children}) : super('form');
}

/// A details disclosure element.
class Details extends DomComponent {
  const Details({super.attributes, super.children}) : super('details');
}

/// A summary element used inside [Details].
class Summary extends DomComponent {
  const Summary({super.attributes, super.children}) : super('summary');
}

/// A self-closing input element.
class Input extends DomComponent {
  const Input({super.attributes}) : super('input');

  @override
  Iterable<Component> build() => [];
}

/// A button element.
class Button extends DomComponent {
  const Button({super.attributes, super.children}) : super('button');
}

/// A self-closing image element.
class Img extends DomComponent {
  const Img({super.attributes}) : super('img');

  @override
  Iterable<Component> build() => [];
}

/// A self-closing line break element.
class Br extends DomComponent {
  const Br() : super('br');

  @override
  Iterable<Component> build() => [];
}

/// A self-closing horizontal rule element.
class Hr extends DomComponent {
  const Hr() : super('hr');

  @override
  Iterable<Component> build() => [];
}

/// A script element, supporting embedded text or a CDATA-wrapped script body.
class Script extends DomComponent {
  final String? src;
  final bool? async;
  final String? type;
  final String? content;
  final bool? contentInCDATA;
  final Iterable<Component>? childrenz;

  Script({
    this.src,
    this.async,
    this.type,
    this.content,
    this.contentInCDATA,
    this.childrenz,
  }) : super(
         'script',
         attributes: {
           'src': ?src,
           'type': ?type,
           if (async != null) 'async': async.toString(),
         },
         children:
             childrenz ??
             (content != null
                 ? [
                     if (contentInCDATA == true)
                       RawText('//<![CDATA[\n$content\n//]]>')
                     else
                       Text(content),
                   ]
                 : null),
       );
}

/// Converts a plain attribute map into Blogger expression attributes.
Map<String, String> expr(Map<String, String> attributes) {
  return attributes.map((key, value) => MapEntry('expr:$key', value));
}

/// Helper methods for Blogger `expr:` and `data:` expression values.
class Expr {
  /// Creates a Blogger expression attribute for the given [key].
  static Map<String, String> attr(String key, String value) => {
    'expr:$key': value,
  };

  /// Returns a Blogger data reference for [value].
  static String get(String value) => 'data:$value';

  /// Creates a Blogger resizeImage expression.
  static String resizeImage(
    String imageUrl,
    int newSize, [
    String? ratio,
    String? crop,
  ]) {
    var args = [imageUrl, newSize.toString()];
    if (ratio != null) args.add('"$ratio"');
    if (crop != null) args.add('"$crop"');
    return 'resizeImage(${args.join(", ")})';
  }
}

/// Known Blogger data references for use inside `expr:` values.
class Data {
  // Global Blog Data
  static const String blogTitle = 'data:blog.title';
  static const String blogUrl = 'data:blog.url';
  static const String blogPageTitle = 'data:blog.pageTitle';
  static const String blogPageType = 'data:blog.pageType';
  static const String blogHomepageUrl = 'data:blog.homepageUrl';
  static const String blogEncoding = 'data:blog.encoding';
  static const String blogLanguageDirection = 'data:blog.languageDirection';

  // View Data
  static const String isHomepage = 'data:view.isHomepage';
  static const String isPost = 'data:view.isPost';
  static const String isPage = 'data:view.isPage';
  static const String isSearch = 'data:view.isSearch';
  static const String isArchive = 'data:view.isArchive';
  static const String isMultipleItems = 'data:view.isMultipleItems';
  static const String isSingleItem = 'data:view.isSingleItem';
  static const String isError = 'data:view.isError';

  // Widget specific helpers
  static String widget(String value) => 'data:$value';
}

/// Helper methods for building Blogger feed URLs.
class Feeds {
  /// Builds a feed URL for blog posts with optional query parameters.
  static String posts({
    int? maxResults,
    String? orderBy,
    String? alt,
    String? label,
  }) {
    var path = 'feeds/posts/default';
    if (label != null) path += '/-/$label';
    var params = <String>[];
    if (maxResults != null) params.add('max-results=$maxResults');
    if (orderBy != null) params.add('orderby=$orderBy');
    if (alt != null) params.add('alt=$alt');
    var query = params.isNotEmpty ? '?${params.join("&")}' : '';
    return '${Data.blogHomepageUrl}$path$query';
  }

  static String summary({int? maxResults, String? alt}) {
    var params = <String>[];
    if (maxResults != null) params.add('max-results=$maxResults');
    if (alt != null) params.add('alt=$alt');
    var query = params.isNotEmpty ? '?${params.join("&")}' : '';
    return '${Data.blogHomepageUrl}feeds/summary$query';
  }
}

/////
///
///
/// A span element.
class Span extends DomComponent {
  const Span({super.attributes, super.children}) : super('span');
}

/// A semantic header section element.
class Header extends DomComponent {
  const Header({super.attributes, super.children}) : super('header');
}

/// A semantic footer section element.
class Footer extends DomComponent {
  const Footer({super.attributes, super.children}) : super('footer');
}

/// A semantic main content section.
class Main extends DomComponent {
  const Main({super.attributes, super.children}) : super('main');
}

/// A semantic navigation section.
class Nav extends DomComponent {
  const Nav({super.attributes, super.children}) : super('nav');
}

/// A generic section element.
class Section extends DomComponent {
  const Section({super.attributes, super.children}) : super('section');
}

/// A semantic article section.
class Article extends DomComponent {
  const Article({super.attributes, super.children}) : super('article');
}

/// A semantic aside section.
class Aside extends DomComponent {
  const Aside({super.attributes, super.children}) : super('aside');
}

/// A level 1 heading element.
class H1 extends DomComponent {
  const H1({super.attributes, super.children}) : super('h1');
}

/// A level 2 heading element.
class H2 extends DomComponent {
  const H2({super.attributes, super.children}) : super('h2');
}

/// A level 3 heading element.
class H3 extends DomComponent {
  const H3({super.attributes, super.children}) : super('h3');
}

/// A level 4 heading element.
class H4 extends DomComponent {
  const H4({super.attributes, super.children}) : super('h4');
}

/// A level 5 heading element.
class H5 extends DomComponent {
  const H5({super.attributes, super.children}) : super('h5');
}

/// A level 6 heading element.
class H6 extends DomComponent {
  const H6({super.attributes, super.children}) : super('h6');
}

/// A paragraph element.
class P extends DomComponent {
  const P({super.attributes, super.children}) : super('p');
}

/// An unordered list element.
class Ul extends DomComponent {
  const Ul({super.attributes, super.children}) : super('ul');
}

/// A list item element.
class Li extends DomComponent {
  const Li({super.attributes, super.children}) : super('li');
}

/// An anchor element.
class A extends DomComponent {
  const A({super.attributes, super.children}) : super('a');
}

/// A label element.
class Label extends DomComponent {
  const Label({super.attributes, super.children}) : super('label');
}

/// A select dropdown element.
class Select extends DomComponent {
  const Select({super.attributes, super.children}) : super('select');
}

/// An option inside a select dropdown.
class Option extends DomComponent {
  const Option({super.attributes, super.children}) : super('option');
}
