//  <div class='header-center-search'>
//                     <div class='search-container'>
//                         <div class='search-icon'>
//                             &lt;svg fill='none' stroke='currentColor' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'&gt;
//                                 &lt;path d='M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z' stroke-linecap='round' stroke-linejoin='round' stroke-width='2'&gt;&lt;/path&gt;
//                             &lt;/svg&gt;
//                         </div>
//                         <form action='/search' method='get'>
//                             <input class='search-input' name='q' placeholder='Search marketplace services...' type='text'/>
//                         </form>
//                     </div>
//                 </div>

import 'package:blogger_theme/blogger_theme.dart';

final header_center_search = BSection(
  id: 'header-search',
  maxwidgets: 1,
  showaddelement: true,
  children: [
    BWidget(
      id: 'BlogSearch1',
      type: 'BlogSearch',
      locked: false,
      title: 'Search items & services',
      children: [
        BIncludable(
          id: 'main',
          children: [
            Div(
              attributes: {'class': 'header-center-search'},
              children: [
                Div(
                  attributes: {'class': 'search-container'},
                  children: [
                    //why expr:id='data:widget.instanceId + &quot;_form&quot;'
                    Form(
                      attributes: {
                        'expr:action': 'data:blog.searchUrl',
                        'method': 'get',
                        'class': 'search-form',
                      },
                      children: [
                        BAttr(
                          cond: 'not data:view.isPreview',
                          name: 'target',
                          value: '_top',
                        ),
                        Button(
                          attributes: {
                            'class': 'search-icon',
                            'type': 'submit',
                            'aria-label': 'Search',
                          },
                          children: [searchIconSvg],
                        ),
                        Input(
                          attributes: {
                            'class': 'search-input',
                            'name': 'q',
                            'type': 'search',
                            'autocomplete': 'off',
                            'expr:value':
                                'data:view.isSearch ? data:view.search.query.escaped : ""',
                            'expr:placeholder':
                                'data:title != "" and data:title != " " ? data:title + "..." : "Search..."',
                          },
                        ),

                        // input for expr:value='data:messages.search' title='search' type='submit'
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

final searchIconSvg = Svg(
  attributes: {
    'fill': 'none',
    'stroke': 'currentColor',
    'viewBox': '0 0 24 24',
    'xmlns': 'http://www.w3.org/2000/svg',
  },
  children: [
    Path(
      d: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z',
      attributes: {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
      },
    ),
  ],
);
