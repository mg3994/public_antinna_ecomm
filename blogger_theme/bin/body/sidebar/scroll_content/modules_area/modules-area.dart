// <!-- Workspace Options Accordion Menu Area (Managed via Blogger LinkList Widget) -->
//                 <div class='sidebar-modules-area'>
//                     <b:section class='sidebar-modules-section' id='sidebar-workspace-links' maxwidgets='1' showaddelement='yes'>
//                         <b:widget id='LinkList3' locked='false' title='Workspace Menu' type='LinkList' version='2'>
//                             <b:widget-settings>
//                                 <b:widget-setting name='text-0'>Nearby Helpers</b:widget-setting>
//                                 <b:widget-setting name='link-0'>#</b:widget-setting>
//                                 <b:widget-setting name='text-1'>Active Bookings</b:widget-setting>
//                                 <b:widget-setting name='link-1'>#</b:widget-setting>
//                                 <b:widget-setting name='text-2'>Customer Reviews</b:widget-setting>
//                                 <b:widget-setting name='link-2'>#</b:widget-setting>
//                             </b:widget-settings>
//                             <b:includable id='main'>
//                                 <div class='module-wrapper'>
//                                     <button class='module-trigger' onclick='toggleModuleDropdown("workspace-module")'>
//                                         <span>Workspace Options</span>
//                                         <span class='arrow-indicator initial-open' id='workspace-module-arrow'>▾</span>
//                                     </button>
//                                     <ul class='module-dropdown-list' id='workspace-module'>
//                                         <b:loop values='data:links' var='link'>
//                                             <li>
//                                                 <a class='nav-route-link' expr:href='data:link.target'><data:link.name/></a>
//                                             </li>
//                                         </b:loop>
//                                     </ul>
//                                 </div>
//                             </b:includable>
//                         </b:widget>
//                     </b:section>
//                 </div>

import 'package:blogger_theme/blogger_theme.dart';

final sidebar_modules_area = Div(
  attributes: {'class': 'sidebar-modules-area'},
  children: [
    BSection(
      className: 'sidebar-modules-section',
      id: 'sidebar-workspace-links',
      maxwidgets: 1,
      showaddelement: true,
      children: [
        BWidget(
          id: 'LinkList3',
          type: 'LinkList',
          locked: false,
          title: 'Workspace Menu',
          version: 2,
          children: [
            BWidgetSettings(
              children: [
                BWidgetSetting(
                  name: 'text-0',
                  children: ["Nearby Helpers".component],
                ),
                BWidgetSetting(name: 'link-0', children: ["#".component]),
                BWidgetSetting(
                  name: 'text-1',
                  children: ["Active Bookings".component],
                ),
                BWidgetSetting(name: 'link-1', children: ["#".component]),
                BWidgetSetting(
                  name: 'text-2',
                  children: ["Customer Reviews".component],
                ),
                BWidgetSetting(name: 'link-2', children: ["#".component]),
              ],
            ),
            BIncludable(
              id: 'main',
              children: [
                Div(
                  attributes: {'class': 'module-wrapper'},
                  children: [
                    Button(
                      attributes: {
                        'class': 'module-trigger',
                        'onclick': 'toggleModuleDropdown("workspace-module")',
                      },
                      children: [
                        Span(
                          children: [
                            BEval(
                              expr:
                                  'data:title != "" and data:title != " " ? data:title : ""',
                            ),
                          ],
                        ),
                        Span(
                          attributes: {
                            'class': 'arrow-indicator initial-open',
                            'id': 'workspace-module-arrow',
                          },
                          children: ["▾".component],
                        ),
                      ],
                    ),
                    Ul(
                      attributes: {
                        'class': 'module-dropdown-list',
                        'id': 'workspace-module',
                      },
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
