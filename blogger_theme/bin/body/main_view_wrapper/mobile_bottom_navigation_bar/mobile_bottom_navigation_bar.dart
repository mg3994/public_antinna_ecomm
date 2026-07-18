// //  <!-- STICKY MOBILE TAB-BAR NAVIGATION SYSTEM (Safely nested here to appear inside Blogger Layout Editor) -->
// //           <b:section class='mobile-bottom-navigation-bar' id='sidebar-widgets' maxwidgets='5' showaddelement='yes'>
// //               <b:widget id='LinkList1' locked='false' title='Navigation Menu' type='LinkList' version='2'>
// //                   <b:widget-settings>
// //                       <b:widget-setting name='text-0'>Home</b:widget-setting>
// //                       <b:widget-setting name='link-0'>/</b:widget-setting>
// //                       <b:widget-setting name='text-1'>Services</b:widget-setting>
// //                       <b:widget-setting name='link-1'>/search/label/Services</b:widget-setting>
// //                       <b:widget-setting name='text-2'>Salons</b:widget-setting>
// //                       <b:widget-setting name='link-2'>/search/label/Salons</b:widget-setting>
// //                       <b:widget-setting name='text-3'>Bookings</b:widget-setting>
// //                       <b:widget-setting name='link-3'>/p/bookings.html</b:widget-setting>
// //                   </b:widget-settings>
// //                   <b:includable id='main'>
// //                       <ul class='bottom-nav-list'>
// //                           <b:loop values='data:links' var='link'>
// //                               <li class='bottom-nav-item'>
// //                                   <a class='nav-route-link' expr:href='data:link.target'>
// //                                       <span class='bottom-nav-icon-dot'>•</span>
// //                                       <span class='bottom-nav-text'><data:link.name/></span>
// //                                   </a>
// //                               </li>
// //                           </b:loop>
// //                       </ul>
// //                   </b:includable>
// //               </b:widget>
// //           </b:section>

// import 'package:blogger_theme/blogger_theme.dart';

// final mobile_bottom_navigation_bar = BSection(
//   className: 'mobile-bottom-navigation-bar',
//   id: 'sidebar-widgets',
//   maxwidgets: 5, // Comented by Manish
//   showaddelement: true,
//   children: [
//     BWidget(
//       id: 'LinkList1',
//       type: 'LinkList',
//       locked: false,
//       title: 'Navigation Menu',
//       version: 2,
//       children: [
//         BWidgetSettings(
//           children: [
//             BWidgetSetting(name: 'text-0', children: ["Home".component]),
//             BWidgetSetting(name: 'link-0', children: ["/".component]),
//             BWidgetSetting(name: 'text-1', children: ["".component]),
//             BWidgetSetting(
//                 name: 'link-1', children: ["/search/label/Services".component]),
//             BWidgetSetting(name: 'text-2', children: ["Salons".component]),
//             BWidgetSetting(
//                 name: 'link-2', children: ["/search/label/Salons".component]),
//             BWidgetSetting(name: 'text-3', children: ["Bookings".component]),
//             BWidgetSetting(
//                 name: 'link-3', children: ["/p/bookings.html".component]),
//           ],
//         ),
//         BIncludable(id: "main", children: [
//           Ul(attributes: {
//             'class': 'bottom-nav-list'
//             // must add id
//           }, children: [
//             BLoop(values: "data:links", varName: "link", children: [
//               Li(attributes: {
//                 'class': 'bottom-nav-item'
//               }, children: [
//                 A(attributes: {
//                   'class': 'nav-route-link',
//                   'expr:href': "data:link.target"
//                 }, children: [
//                   Span(
//                       attributes: {'class': 'bottom-nav-icon-dot'},
//                       children: ["•".component]),
//                   Span(
//                       attributes: {'class': 'bottom-nav-text'},
//                       children: [BData(value: 'link.name')]),
//                 ])
//               ])
//             ])
//           ])
//         ]),
//       ],
//     ),
//   ],
// );
