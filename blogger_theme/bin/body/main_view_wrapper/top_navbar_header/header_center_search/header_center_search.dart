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
                Form(
                  attributes: {
                    'expr:action': 'data:blog.searchUrl',
                    'id': 'search-form',
                    'method': 'get',
                    'class': 'search-form-v2',
                  },
                  children: [
                    BAttr(
                      cond: 'not data:view.isPreview',
                      name: 'target',
                      value: '_top',
                    ),

                    // "What" Input Group
                    Div(
                      attributes: {
                        'class': 'search-input-group',
                        'style': 'position: relative;',
                      },
                      children: [
                        Span(
                          attributes: {'class': 'search-icon-v2'},
                          children: [whatSearchIconSvg],
                        ),
                        Input(
                          attributes: {
                            'autocomplete': 'off',
                            'class': 'search-input-v2',
                            'id': 'search-q',
                            'name': 'q',
                            'placeholder': 'Service title, keywords, or company',
                            'type': 'text',
                          },
                        ),
                      ],
                    ),

                    Div(attributes: {'class': 'search-divider'}),

                    // "Where" Input Group
                    Div(
                      attributes: {
                        'class': 'search-input-group',
                        'onclick': 'window.LocationRenderer.showModal()',
                      },
                      children: [
                        Span(
                          attributes: {'class': 'search-icon-v2'},
                          children: [whereLocationIconSvg],
                        ),
                        Input(
                          attributes: {
                            'autocomplete': 'off',
                            'class': 'search-input-v2',
                            'id': 'loc-display-v2',
                            'placeholder': 'City, PIN code',
                            'readonly': 'readonly',
                            'type': 'text',
                          },
                        ),
                      ],
                    ),

                    Button(
                      attributes: {
                        'class': 'search-btn-v2',
                        'type': 'submit',
                      },
                      children: [Text('Find')],
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

final whatSearchIconSvg = Svg(
  attributes: {
    'viewBox': '0 0 24 24',
    'xmlns': 'http://www.w3.org/2000/svg',
  },
  children: [
    Path(
      d: 'M9.452 16.137c-1.852 0-3.422-.643-4.708-1.929s-1.93-2.856-1.93-4.708c0-1.853.644-3.422 1.93-4.708C6.03 3.505 7.6 2.862 9.452 2.862c1.853 0 3.422.643 4.708 1.93 1.287 1.286 1.93 2.855 1.93 4.708a6.25 6.25 0 01-.338 2.078 5.93 5.93 0 01-.915 1.704l5.553 5.558c.21.215.316.481.316.799 0 .317-.107.581-.322.792a1.08 1.08 0 01-.796.317c-.32 0-.584-.106-.796-.317l-5.546-5.546a5.991 5.991 0 01-1.716.914 6.284 6.284 0 01-2.078.338zm0-2.275c1.214 0 2.245-.423 3.092-1.27s1.27-1.878 1.27-3.092c0-1.214-.423-2.245-1.27-3.092s-1.878-1.27-3.092-1.27c-1.214 0-2.245.423-3.092 1.27S5.09 8.286 5.09 9.5c0 1.214.423 2.245 1.27 3.092s1.878 1.27 3.092 1.27z',
    ),
  ],
);

final whereLocationIconSvg = Svg(
  attributes: {
    'viewBox': '0 0 24 24',
    'xmlns': 'http://www.w3.org/2000/svg',
  },
  children: [
    Path(
      d: 'M12 19.188c2.005-1.834 3.495-3.49 4.468-4.964.974-1.476 1.46-2.825 1.46-4.048 0-1.789-.572-3.253-1.717-4.394-1.144-1.14-2.548-1.71-4.211-1.71-1.664 0-3.067.57-4.212 1.71-1.144 1.14-1.716 2.605-1.716 4.394 0 1.223.486 2.571 1.46 4.045.973 1.473 2.462 3.129 4.468 4.967zm-.002 2.304c-.248 0-.496-.043-.743-.13a1.963 1.963 0 01-.664-.394 40.642 40.642 0 01-2.935-2.949c-.849-.954-1.558-1.88-2.126-2.78-.568-.9-1-1.77-1.293-2.614-.294-.843-.44-1.66-.44-2.45 0-2.554.824-4.589 2.473-6.105C7.92 2.555 9.83 1.797 12 1.797c2.17 0 4.08.758 5.73 2.273 1.648 1.516 2.473 3.551 2.473 6.106 0 .79-.147 1.606-.44 2.45-.294.842-.725 1.713-1.293 2.613-.569.9-1.277 1.826-2.127 2.78a40.646 40.646 0 01-2.934 2.95 1.967 1.967 0 01-.666.392 2.234 2.234 0 01-.745.131zM12 12.06c.57 0 1.056-.201 1.457-.603.402-.401.603-.887.603-1.457 0-.57-.201-1.056-.603-1.457A1.984 1.984 0 0012 7.94c-.57 0-1.056.201-1.457.603A1.985 1.985 0 009.94 10c0 .57.201 1.056.603 1.457.401.402.887.603 1.457.603z',
    ),
  ],
);
