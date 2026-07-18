//  <!-- Platform Legal Privacy Policy Links Framework Managed via Blogger Backend LinkList Widget -->
//               <div class='sidebar-legal-area'>
//                   <b:section class='sidebar-legal-section' id='sidebar-legal-links' maxwidgets='1' showaddelement='yes'>
//                       <b:widget id='LinkList2' locked='false' title='Legal Pages Menu' type='LinkList' version='2'>
//                           <b:widget-settings>
//                               <b:widget-setting name='text-0'>Privacy Policy</b:widget-setting>
//                               <b:widget-setting name='link-0'>/p/privacy-policy.html</b:widget-setting>
//                               <b:widget-setting name='text-1'>Terms &amp; Conditions</b:widget-setting>
//                               <b:widget-setting name='link-1'>/p/terms-conditions.html</b:widget-setting>
//                               <b:widget-setting name='text-2'>Refund Policy</b:widget-setting>
//                               <b:widget-setting name='link-2'>/p/refund-cancellation.html</b:widget-setting>
//                               <b:widget-setting name='text-3'>Disclaimer</b:widget-setting>
//                               <b:widget-setting name='link-3'>/p/disclaimer.html</b:widget-setting>
//                           </b:widget-settings>
//                           <b:includable id='main'>
//                               <div class='module-wrapper'>
//                                   <button class='module-trigger' onclick='toggleModuleDropdown("legal-policy-module")'>
//                                       <span>Policies &amp; Legal</span>
//                                       <span class='arrow-indicator' id='legal-policy-module-arrow'>▾</span>
//                                   </button>
//                                   <ul class='module-dropdown-list ui-hidden' id='legal-policy-module'>
//                                       <b:loop values='data:links' var='link'>
//                                           <li>
//                                               <a class='nav-route-link' expr:href='data:link.target'><data:link.name/></a>
//                                           </li>
//                                       </b:loop>
//                                   </ul>
//                               </div>
//                           </b:includable>
//                       </b:widget>
//                   </b:section>
//               </div>

import 'package:blogger_theme/blogger_theme.dart';

final sidebar_legal_area = Div(
  attributes: {'class': 'sidebar-legal-area'},
  children: [
    BSection(
      className: 'sidebar-legal-section',
      id: 'sidebar-legal-links',
      maxwidgets: 1,
      showaddelement: true,
      children: [
        BWidget(
          id: 'LinkList2',
          type: 'LinkList',
          locked: false,
          title: 'Policies & Legal',
          version: 2,
          children: [
            BWidgetSettings(
              children: [
                BWidgetSetting(
                  name: 'text-0',
                  children: ["Privacy Policy".component],
                ),
                BWidgetSetting(
                  name: 'link-0',
                  children: ["/p/privacy-policy.html".component],
                ),
                BWidgetSetting(
                  name: 'text-1',
                  children: ["Terms & Conditions".component],
                ),
                BWidgetSetting(
                  name: 'link-1',
                  children: ["/p/terms-conditions.html".component],
                ),
                BWidgetSetting(
                  name: 'text-2',
                  children: ["Refund Policy".component],
                ),
                BWidgetSetting(
                  name: 'link-2',
                  children: ["/p/refund-cancellation.html".component],
                ),
                BWidgetSetting(
                  name: 'text-3',
                  children: ["Disclaimer".component],
                ),
                BWidgetSetting(
                  name: 'link-3',
                  children: ["/p/disclaimer.html".component],
                ),
              ],
            ),
            // The includable content would be implemented here as needed
            BIncludable(
              id: 'main',
              children: [
                Div(
                  attributes: {'class': 'module-wrapper'},
                  children: [
                    Button(
                      attributes: {
                        'class': 'module-trigger',
                        'onclick':
                            'toggleModuleDropdown("legal-policy-module")',
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
                            'class': 'arrow-indicator',
                            'id': 'legal-policy-module-arrow',
                          },
                          children: ["▾".component],
                        ),
                      ],
                    ),
                    Ul(
                      attributes: {
                        'class': 'module-dropdown-list ui-hidden',
                        'id': 'legal-policy-module',
                      },
                      children: [
                        // The loop to generate list items from data would be implemented here as needed
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
