// <div class='header-right'>
//                     <button class='btn-theme-toggle' id='theme-mode-switcher'>
//                         <span class='mode-icon icon-moon'>&#9790;</span>
//                         <span class='mode-icon icon-sun ui-hidden'>&#9728;</span>
//                     </button>
//                 </div>

import 'package:blogger_theme/blogger_theme.dart';
final header_right = Div(attributes: {
  'class': 'header-right',
}, children: [
  Button(attributes: {
    'class': 'btn-theme-toggle',
    'id': 'theme-mode-switcher'
  }, children: [
    Span(attributes: {
      'class': 'mode-icon icon-moon'
    }, children: [Text('☾')]),
    Span(attributes: {
      'class': 'mode-icon icon-sun ui-hidden'
    }, children: [Text('☼')])
  ])
]);