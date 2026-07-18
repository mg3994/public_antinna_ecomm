import 'package:blogger_theme/blogger_theme.dart';

/// viewport Related Meta tags
final meta_viewport_head = Meta(
  attributes: {
    "content": "width=device-width, initial-scale=1.0",
    "name": "viewport"
  },
);

///All Blogger Meta tags Auto added by blogger platform
final meta_blogger_all_head_content_head =
    BInclude(name: "all-head-content", data: "blog");

/// Open Graph Meta tags

final meta_og_type_head = Meta(
  attributes: {"property": "og:type", "content": "website"},
);

final meta_geo_region_head = Meta(
  attributes: {"name": "geo.region", "content": "IN-HR"},
);

final meta_contact_phone_head = Meta(
  attributes: {"name": "contact.phone", "content": "+918607573994"},
);

/// content Rating
final meta_isAdultContent_head = BIf(cond: "data:blog.adultContent", children: [
  Meta(
    attributes: {"name": "rating", "content": "adult"},
  )
]);

final meta_isGeneralContent_head =
    BIf(cond: "!data:blog.adultContent", children: [
  Meta(
    attributes: {"name": "rating", "content": "general"},
  )
]);

final meta_is_google_analytics_head = BIf(
    cond: "data:blog.analyticsAccountNumber",
    children: [BInclude(name: "google-analytics", data: "blog")]);

final meta_subject_head = Meta(attributes: {
  "name": "subject",
  ...Expr.attr('content',
      '(data:view.isMultipleItems ? data:blog.pageTitle : data:view.title).escaped'),
});

final meta_is_metaDescription_head =
    BIf(cond: "data:blog.metaDescription", children: [
  Meta(attributes: {
    "name": "description",
    ...Expr.attr('content', 'data:blog.metaDescription'),
  })
]);
