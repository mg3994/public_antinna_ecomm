import 'package:blogger_theme/blogger_theme.dart';
import 'brand.dart' hide brand_logo;

final brand_logo = Div(
    attributes: {'class': 'brand-logo'}, children: [brand_icon, brand_text]);
