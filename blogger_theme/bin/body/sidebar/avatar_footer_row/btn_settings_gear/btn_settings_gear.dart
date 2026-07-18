// <button aria-label='Settings' class='btn-settings-gear' onclick='alert("Settings panel active!")'>&#9881;</button>

import 'package:blogger_theme/blogger_theme.dart';

final btn_settings_gear = Button(attributes: {
  'aria-label': 'Settings',
  'class': 'btn-settings-gear',
  'onclick': 'alert("Settings panel active!")'
}, children: [
  Text('⚙')
]);
