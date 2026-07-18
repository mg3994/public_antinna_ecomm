import 'package:blogger_theme/blogger_theme.dart';

// <!-- Primary Application Core Static Navigation Paths -->
// <div class='desktop-nav-fallback'>
//     <ul class='sidebar-static-links'>
//         <li><a class='nav-route-link' href='/'>Home</a></li>
//         <li><a class='nav-route-link' href='/search/label/Services'>Services</a></li>
//         <li><a class='nav-route-link' href='/search/label/Salons'>Salons</a></li>
//         <li><a class='nav-route-link' href='/p/bookings.html'>Bookings</a></li>
//     </ul>
// </div>
final desktop_nav_fallback = Div(
  attributes: {'class': 'desktop-nav-fallback'},
  children: [
    BSection(
      className: 'sidebar-shared-nav-section',
      id: 'sidebar-primary-links',
      maxwidgets: 1,
      showaddelement: true,
      children: [
        BWidget(
          id: 'LinkList1',
          locked: false,
          title: 'Navigation Menu',
          type: 'LinkList',
          version: 2,
          children: [
            // All Icons are taken from https://icon-sets.iconify.design/picon/ so name your nae wisely
            BWidgetSettings(
              children: [
                // BWidgetSetting(name: 'icon-0', children: [Text('🏠')]),
                BWidgetSetting(name: 'text-0', children: [Text("house")]),
                BWidgetSetting(name: 'link-0', children: [Text("/")]),

                //
                // BWidgetSetting(name: 'icon-1', children: [Text('🛠️')]),
                BWidgetSetting(name: 'text-1', children: [Text("shop")]),
                BWidgetSetting(name: 'link-1', children: [Text("/search/")]),
                //
                // BWidgetSetting(name: 'icon-2', children: [Text('🛒')]),
                BWidgetSetting(name: 'text-2', children: [Text("fix")]),
                BWidgetSetting(
                  name: 'link-2',
                  children: [Text("/search/label/Services")],
                ),
                //
                // BWidgetSetting(name: 'icon-2', children: [Text("📦")]),
                BWidgetSetting(name: 'text-3', children: [Text("Profile")]),
                BWidgetSetting(
                  name: 'link-3',
                  children: [Text("/p/profile.html")],
                ),
              ],
            ),

            BIncludable(
              id: 'main',
              children: [
                Ul(
                  attributes: {'class': 'sidebar-static-links'},
                  children: [
                    BLoop(
                      values: 'data:links',
                      varName: 'link',
                      children: [
                        Li(
                          children: [
                            A(
                              attributes: {
                                'class': 'nav-route-link',
                                'expr:href': 'data:link.target',
                              },
                              children: [BData(value: 'link.name')],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // <!-- 2. MOBILE VIEW NATIVE RENDER -->
                //                 <div class='mobile-bottom-navigation-bar'>
                //                     <ul class='bottom-nav-list'>
                //                         <b:loop values='data:links' var='link'>
                //                             <li class='bottom-nav-item'>
                //                                 <a class='nav-route-link' expr:href='data:link.target'>
                //                                     <span class='bottom-nav-icon-dot'>•</span>
                //                                     <span class='bottom-nav-text'><data:link.name/></span>
                //                                 </a>
                //                             </li>
                //                         </b:loop>
                //                     </ul>
                //                 </div>
                Div(
                  attributes: {'class': 'mobile-bottom-navigation-bar'},
                  children: [
                    Ul(
                      attributes: {'class': 'bottom-nav-list'},
                      children: [
                        BLoop(
                          values: 'data:links',
                          varName: 'link',
                          children: [
                            Li(
                              attributes: {'class': 'bottom-nav-item'},
                              children: [
                                A(
                                  attributes: {
                                    'class': 'nav-route-link',
                                    'expr:href': 'data:link.target',
                                  },
                                  children: [
                                    BIf(
                                      cond:
                                          'data:link.name != " "', // 'data:link.icon != ""',
                                      children: [
                                        // Span(
                                        //   attributes: {
                                        //     'class': 'bottom-nav-icon-dot',
                                        //   },
                                        //   children: [

                                        //     // BData(value: 'link.name'),
                                        //     // BData(value: 'link.icon'),
                                        //   ], // i want that icon somehow
                                        // ),
                                        // Img(
                                        //   attributes: {
                                        //     'class': 'bottom-nav-icon-dot',
                                        //     'loading':
                                        //         'lazy', // Good practice for navigation icons
                                        //     'expr:src':
                                        //         '"https://api.iconify.design/mdi/" + data:link.name + ".svg"', // what i want is i want data:link.name be all small snake case

                                        //     'expr:alt': 'data:link.name',
                                        //     'width':
                                        //         '22', // Define size to prevent CLS
                                        //     'height': '22',
                                        //     // .... external api service + data:link.name
                                        //   },
                                        // ),

                                        ///
                                        Span(
                                          attributes: {
                                            'class': 'bottom-nav-icon-dot',
                                            // This injects the dynamic URL into a CSS variable
                                            'expr:style':
                                                '"--icon-url: url(https://api.iconify.design/picon/" + data:link.name + ".svg)"',
                                          },
                                        ),
                                        Span(
                                          attributes: {
                                            'class': 'bottom-nav-text',
                                          },
                                          children: [
                                            //
                                            BData(value: 'link.name'),
                                          ],
                                        ),
                                        /////
                                        BElse(),
                                        Span(
                                          attributes: {
                                            'class': 'bottom-nav-icon-dot',
                                          },
                                          children: [Text('•')],
                                        ),
                                        Span(
                                          attributes: {
                                            'class': 'bottom-nav-text',
                                          },
                                          children: [BData(value: 'link.name')],
                                        ),
                                      ],
                                    ),
                                    //

                                    //
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    ////
  ],
);
