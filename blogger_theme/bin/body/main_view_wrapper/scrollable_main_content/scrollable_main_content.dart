import 'package:blogger_theme/blogger_theme.dart';
import 'blog_posts_widget.dart';

final scrollable_main_content = Main(
  attributes: {'class': 'scrollable-main-content'},
  children: [
    BSection(
      className: 'main-feed-section',
      id: 'main-section',
      showaddelement: true,
      children: [
        blog_posts_widget,
      ],
    ),
  ],
);
