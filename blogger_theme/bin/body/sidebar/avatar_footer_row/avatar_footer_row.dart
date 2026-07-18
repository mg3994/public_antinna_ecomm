// import 'avatar_left_info/avatar_left_info.dart';
import 'package:blogger_theme/blogger_theme.dart';
import 'avatar_left_info/avatar_left_info.dart';
import 'btn_settings_gear/btn_settings_gear.dart';

final avatar_footer_row = Div(attributes: {
  'class': 'avatar-footer-row',
}, children: [
  avatar_left_info,
  btn_settings_gear
]);
