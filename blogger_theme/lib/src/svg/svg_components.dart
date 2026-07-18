import '../core.dart';

/// A root SVG element containing vector graphic children.
class Svg extends DomComponent {
  Svg({
    String? viewBox,
    String? width,
    String? height,
    String? fill,
    String? stroke,
    String? strokeWidth,
    String? strokeLinecap,
    String? strokeLinejoin,
    Map<String, String>? attributes,
    Iterable<Component>? children,
  }) : super(
         'svg',
         attributes: {
           'viewBox': ?viewBox,
           'width': ?width,
           'height': ?height,
           'fill': ?fill,
           'stroke': ?stroke,
           'stroke-width': ?strokeWidth,
           'stroke-linecap': ?strokeLinecap,
           'stroke-linejoin': ?strokeLinejoin,
           ...?attributes,
         },
         children: children,
       );
}

/// An SVG path element with a drawing command string.
class Path extends DomComponent {
  Path({
    required String d,
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
  }) : super(
         'path',
         attributes: {'d': d, 'fill': ?fill, 'stroke': ?stroke, ...?attributes},
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG rectangle element.
class Rect extends DomComponent {
  Rect({
    String? x,
    String? y,
    String? width,
    String? height,
    String? rx,
    String? ry,
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
  }) : super(
         'rect',
         attributes: {
           'x': ?x,
           'y': ?y,
           'width': ?width,
           'height': ?height,
           'rx': ?rx,
           'ry': ?ry,
           'fill': ?fill,
           'stroke': ?stroke,
           ...?attributes,
         },
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG circle element.
class Circle extends DomComponent {
  Circle({
    required String cx,
    required String cy,
    required String r,
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
  }) : super(
         'circle',
         attributes: {
           'cx': cx,
           'cy': cy,
           'r': r,
           'fill': ?fill,
           'stroke': ?stroke,
           ...?attributes,
         },
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG line element.
class Line extends DomComponent {
  Line({
    required String x1,
    required String y1,
    required String x2,
    required String y2,
    String? stroke,
    String? strokeWidth,
    Map<String, String>? attributes,
  }) : super(
         'line',
         attributes: {
           'x1': x1,
           'y1': y1,
           'x2': x2,
           'y2': y2,
           'stroke': ?stroke,
           'stroke-width': ?strokeWidth,
           ...?attributes,
         },
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG polygon element.
class Polygon extends DomComponent {
  Polygon({
    required String points,
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
  }) : super(
         'polygon',
         attributes: {
           'points': points,
           'fill': ?fill,
           'stroke': ?stroke,
           ...?attributes,
         },
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG polyline element.
class Polyline extends DomComponent {
  Polyline({
    required String points,
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
  }) : super(
         'polyline',
         attributes: {
           'points': points,
           'fill': ?fill,
           'stroke': ?stroke,
           ...?attributes,
         },
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG ellipse element.
class Ellipse extends DomComponent {
  Ellipse({
    required String cx,
    required String cy,
    required String rx,
    required String ry,
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
  }) : super(
         'ellipse',
         attributes: {
           'cx': cx,
           'cy': cy,
           'rx': rx,
           'ry': ry,
           'fill': ?fill,
           'stroke': ?stroke,
           ...?attributes,
         },
       );

  @override
  Iterable<Component> build() => [];
}

/// An SVG group element that can contain other SVG shapes.
class G extends DomComponent {
  G({
    String? fill,
    String? stroke,
    Map<String, String>? attributes,
    Iterable<Component>? children,
  }) : super(
         'g',
         attributes: {'fill': ?fill, 'stroke': ?stroke, ...?attributes},
         children: children,
       );
}
