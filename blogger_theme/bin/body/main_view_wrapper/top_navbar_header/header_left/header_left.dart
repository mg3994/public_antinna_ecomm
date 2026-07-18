// <div class='header-left'>
//                   <button class='btn-hamburger' onclick='toggleSidebarDrawer()'>&#9776;</button>
//               </div>

import 'package:blogger_theme/blogger_theme.dart';

final header_left = Div(
  attributes: {'class': 'header-left'},
  children: [
    Button(
      attributes: {
        'class': 'btn-hamburger',
        // 'id': "hamburger-btn",
        'onclick': 'toggleSidebarDrawer()',
      },
      children: [Text('☰')],
    ),
  ],
);
