//  <!-- Platform Social Accounts Profile Hyperlink Matrix -->
//                 <div class='sidebar-social-wrapper'>
//                     &lt;a aria-label='YouTube' class='social-icon-link' href='https://www.youtube.com/@Antinna' target='_blank'&gt;
//                         &lt;svg fill='none' height='18' stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' viewBox='0 0 24 24' width='18'&gt;&lt;path d='M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 11.75a29 29 0 0 0 .46 5.33A2.78 2.78 0 0 0 3.4 19c1.72.46 8.6.46 8.6.46s6.88 0 8.6-.46a2.78 2.78 0 0 0 1.94-2 29 29 0 0 0 .46-5.25 29 29 0 0 0-.46-5.33z'/&gt;&lt;polygon points='9.75 15.02 15.5 11.75 9.75 8.48 9.75 15.02'/&gt;&lt;/svg&gt;
//                     &lt;/a&gt;
//                     &lt;a aria-label='Instagram' class='social-icon-link' href='https://www.instagram.com/antinna.yt' target='_blank'&gt;
//                         &lt;svg fill='none' height='18' stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' viewBox='0 0 24 24' width='18'&gt;&lt;rect height='20' rx='5' ry='5' width='20' x='2' y='2'/&gt;&lt;path d='M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z'/&gt;&lt;line x1='17.5' x2='17.51' y1='6.5' y2='6.5'/&gt;&lt;/svg&gt;
//                     &lt;/a&gt;
//                     &lt;a aria-label='Facebook' class='social-icon-link' href='https://www.facebook.com/profile.php?id=100082961891641' target='_blank'&gt;
//                         &lt;svg fill='none' height='18' stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' viewBox='0 0 24 24' width='18'&gt;&lt;path d='M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z'/&gt;&lt;/svg&gt;
//                     &lt;/a&gt;
//                     &lt;a aria-label='Play Store' class='social-icon-link' href='https://play.google.com/store/apps/dev?id=7417258411166270372' target='_blank'&gt;
//                         &lt;svg fill='none' height='18' stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2.5' viewBox='0 0 24 24' width='18'&gt;&lt;rect height='20' rx='2' ry='2' width='14' x='5' y='2'/&gt;&lt;line x1='12' x2='12.01' y1='18' y2='18'/&gt;&lt;/svg&gt;
//                     &lt;/a&gt;
//                 </div>

import 'package:blogger_theme/blogger_theme.dart';

// TODO make Social wrapper link list
final sidebar_social_wrapper = BSection(
  className: 'sidebar-social-wrapper',
  id: 'social-icon-links',
  maxwidgets: 1,
  showaddelement: true,
  children: [
    BWidget(
      id: 'LinkList4',
      type: 'LinkList',
      locked: false,
      title: 'Connect with us',
      version: 2,
      children: [
        BWidgetSettings(
          children: [
            BWidgetSetting(
              name: 'text-0',
              children: [
                "https://api.iconify.design/mdi/youtube.svg".component,
              ],
            ),
            BWidgetSetting(
              name: 'link-0',
              children: ["https://www.youtube.com/@Antinna".component],
            ),
            BWidgetSetting(
              name: 'text-1',
              children: [
                "https://api.iconify.design/mdi/instagram.svg".component,
              ],
            ),
            BWidgetSetting(
              name: 'link-1',
              children: ["https://www.instagram.com/antinna.yt".component],
            ),
            BWidgetSetting(
              name: 'text-2',
              children: [
                "https://api.iconify.design/mdi/facebook.svg".component,
              ],
            ),
            BWidgetSetting(
              name: 'link-2',
              children: [
                "https://www.facebook.com/profile.php?id=100082961891641"
                    .component,
              ],
            ),
            BWidgetSetting(
              name: 'text-3',
              children: [
                "https://api.iconify.design/mdi/google-play.svg".component,
              ],
            ),
            BWidgetSetting(
              name: 'link-3',
              children: [
                "https://play.google.com/store/apps/dev?id=7417258411166270372l"
                    .component,
              ],
            ),
            BWidgetSetting(
              name: 'text-4',
              children: [
                "https://api.iconify.design/mdi/whatsapp.svg".component,
              ],
            ),
            BWidgetSetting(
              name: 'link-4',
              children: ["https://wa.me/+919729323674".component],
            ),
          ],
        ),
        //
        BIncludable(
          id: 'main',
          children: [
            H4(
              children: [
                BEval(
                  expr:
                      'data:title != "" and data:title != " " ? data:title : ""',
                ),
              ],
            ),
            //here
            Div(
              attributes: {"class": "social-icons-row"},
              children: [
                BLoop(
                  values: 'data:links',
                  varName: 'link',
                  children: [
                    A(
                      attributes: {
                        'class': 'social-icon-link',
                        'expr:href': 'data:link.target',
                        'target': '_blank',
                        'expr:style':
                            '"-webkit-mask-image: url(" + data:link.name + "); mask-image: url(" + data:link.name + ");"',
                      },
                      // children: [
                      //   Img(
                      //     attributes: {
                      //       'expr:src': 'data:link.name',
                      //       'width': '18',
                      //       'height': '18',
                      //       'alt': 'Social Icon',
                      //     },
                      //   ),
                      // ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        //
      ],
    ),
  ],
);

//  Div(
//   attributes: {'class': 'sidebar-social-wrapper'},
//   children: [

//     A(
//       attributes: {
//         'aria-label': 'YouTube',
//         'class': 'social-icon-link',
//         'href': 'https://www.youtube.com/@Antinna',
//         'target': '_blank',
//       },
//       children: [
//         Svg(
//           fill: 'none',
//           height: '18',
//           stroke: 'currentColor',
//           strokeLinecap: 'round',
//           strokeLinejoin: 'round',
//           strokeWidth: '2',
//           viewBox: '0 0 24 24',
//           width: '18',
//           children: [
//             //        Path(
//             //   d: 'M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 12a29 29 0 0 0 .46 5.58 2.78 2.78 0 0 0 1.94 2C5.12 20 12 20 12 20s6.88 0 8.6-.42a2.78 2.78 0 0 0 1.94-2A29 29 0 0 0 23 12a29 29 0 0 0-.46-5.58z',
//             // ),
//             // Path(
//             //   d: 'm10 15 5-3-5-3v6z',
//             //   fill: 'currentColor',
//             //   stroke: 'none',
//             // ),
//             // Path(
//             //     d:
//             //         'M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 11.75a29 29 0 0 0 .46 5.33A2.78 2.78 0 0 0 3.4 19c1.72.46 8.6.46 8.6.46s6.88 0 8.6-.46a2.78 2.78 0 0 0 1.94-2 29 29 0 0 0 .46-5.25 29 29 0 0 0-.46-5.33z'
//             //         ),
//             Path(
//               d: 'M23.5 6.2a3 3 0 0 0-2.1-2.1C19.5 3.5 12 3.5 12 3.5s-7.5 0-9.4.6A3 3 0 0 0 .5 6.2 31 31 0 0 0 0 12a31 31 0 0 0 .5 5.8 3 3 0 0 0 2.1 2.1c1.9.6 9.4.6 9.4.6s7.5 0 9.4-.6a3 3 0 0 0 2.1-2.1A31 31 0 0 0 24 12a31 31 0 0 0-.5-5.8zM9.75 15.5v-7L16 12l-6.25 3.5z',
//             ),
//           ],
//         ),
//       ],
//     ),
//     A(
//       attributes: {
//         'aria-label': 'Instagram',
//         'class': 'social-icon-link',
//         'href': 'https://www.instagram.com/antinna.yt',
//         'target': '_blank',
//       },
//       children: [
//         Svg(
//           fill: 'none',
//           height: '18',
//           stroke: 'currentColor',
//           strokeLinecap: 'round',
//           strokeLinejoin: 'round',
//           strokeWidth: '2',
//           viewBox: '0 0 24 24',
//           width: '18',
//           children: [
//             Rect(height: '20', rx: '5', ry: '5', width: '20', x: '2', y: '2'),
//             Path(d: 'M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z'),
//             Line(x1: '17.5', x2: '17.51', y1: '6.5', y2: '6.5'),
//           ],
//         ),
//       ],
//     ),
//     A(
//       attributes: {
//         'aria-label': 'Facebook',
//         'class': 'social-icon-link',
//         'href': 'https://www.facebook.com/profile.php?id=100082961891641',
//         'target': '_blank',
//       },
//       children: [
//         Svg(
//           fill: 'none',
//           height: '18',
//           stroke: 'currentColor',
//           strokeLinecap: 'round',
//           strokeLinejoin: 'round',
//           strokeWidth: '2',
//           viewBox: '0 0 24 24',
//           width: '18',
//           children: [
//             Path(
//               d: 'M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z',
//             ),
//           ],
//         ),
//       ],
//     ),
//     A(
//       attributes: {
//         'aria-label': 'Play Store',
//         'class': 'social-icon-link',
//         'href': 'https://play.google.com/store/apps/dev?id=7417258411166270372',
//         'target': '_blank',
//       },
//       children: [
//         Svg(
//           fill: 'none',
//           height: '18',
//           stroke: 'currentColor',
//           strokeLinecap: 'round',
//           strokeLinejoin: 'round',
//           strokeWidth: '2.5',
//           viewBox: '0 0 24 24',
//           width: '18',
//           children: [
//             Rect(height: '20', rx: '2', ry: '2', width: '14', x: '5', y: '2'),
//             Line(x1: '12', x2: '12.01', y1: '18', y2: '18'),
//           ],
//         ),
//       ],
//     ),
//   ],
// );
