import 'package:blogger_theme/blogger_theme.dart';

import 'user_avatar_circle/user_avatar_circle.dart';
import 'user_meta_strings/user_meta_strings.dart';

final avatar_left_info = Div(attributes: {
  'class': 'avatar-left-info',
}, children: [
  user_avatar_circle,
  user_meta_strings,
]);