import 'package:blogger_theme/blogger_theme.dart';
import 'categories_widget.dart';
import 'blog_posts_widget.dart';

final scrollable_main_content = Main(
  attributes: {'class': 'scrollable-main-content'},
  children: [
    BSection(
      className: 'main-feed-section',
      id: 'main-feed-stream',
      showaddelement: true,
      children: [
        categories_widget,
        blog_posts_widget,
      ],
    ),
  ],
);
