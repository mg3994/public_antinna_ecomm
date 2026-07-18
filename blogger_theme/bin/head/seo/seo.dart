import "meta/meta.dart";
import "link/link.dart";
import "ld_json/ld_json.dart";

final seo_head = [
  // viewport Related Meta tags
  meta_viewport_head,
  // All Blogger Meta tags Auto added by blogger platform
  meta_blogger_all_head_content_head,
  // Open Graph Meta tags
  meta_og_type_head,
  meta_geo_region_head,
  meta_contact_phone_head,
  // Link Related
  link_home_head,
  link_search_head,
  //content Rating
  meta_isGeneralContent_head,
  meta_isAdultContent_head,

  link_alternate_mobile_head,
  link_image_src_Multiple_item_first_featuredImage_head,
  link_image_src_Single_item_featuredImage_head,
  meta_is_google_analytics_head,
  // JSON-LD Structured Data
  ...ld_script_Schemas,
  meta_subject_head,
  meta_is_metaDescription_head
];
