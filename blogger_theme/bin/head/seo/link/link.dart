import 'package:blogger_theme/blogger_theme.dart';

/// All Link Related
final link_home_head = Link(
  attributes: {
    "expr:href": 'data:blog.homepageUrl.canonical',
    "expr:title": 'data:messages.home',
    "rel": 'home',
  },
);

final link_search_head = Link(
  attributes: {
    ...Expr.attr('href', 'data:blog.homepageUrl.canonical path "search"'),
    "expr:title": 'data:messages.search',
    "rel": 'search',
  },
);

// Alternate mobile link (adds m=1 when not a mobile request and URL is canonical)

final link_alternate_mobile_head = BTag(
  name: "link",
  cond:
      '!data:blog.isMobileRequest and data:view.url ==  data:view.url.canonical',
  attributesz: {
    ...Expr.attr('href', 'data:view.url params {m: 1}'),
    "media": 'only screen and (max-width: 640px)',
    'rel': 'alternate',
  },
);

final link_image_src_Multiple_item_first_featuredImage_head = BTag(
  name: "link",
  cond:
      '${Data.isMultipleItems} and data:widgets.Blog.first.posts[0].featuredImage',
  attributesz: {
    ...Expr.attr(
      'href',
      'data:widgets.Blog.first.posts[0].featuredImage resizeImage 1600',
    ),
    'rel': 'image_src',
  },
);

final link_image_src_Single_item_featuredImage_head = BTag(
  name: 'link',
  cond: '${Data.isSingleItem} and data:view.featuredImage',
  attributesz: {
    ...Expr.attr('href', 'data:view.featuredImage resizeImage 1600'),
    'rel': 'image_src',
  },
);
