import 'package:blogger_theme/blogger_theme.dart';

final categories_widget = BWidget(
  id: 'Label1',
  type: 'Label',
  locked: true,
  title: 'Categories',
  version: 2,
  isVisible: true,
  children: [
    BWidgetSettings(
      children: [
        BWidgetSetting(name: 'sorting', children: [Text('ALPHA')]),
        BWidgetSetting(name: 'display', children: [Text('LIST')]),
        BWidgetSetting(name: 'selectedLabelsList', children: []),
        BWidgetSetting(name: 'showType', children: [Text('ALL')]),
        BWidgetSetting(name: 'showFreqNumbers', children: [Text('false')]),
      ],
    ),
    BIncludable(
      id: 'main',
      children: [
        BIf(
          cond: 'data:view.isMultipleItems',
          children: [
            Div(
              attributes: {'class': 'cat-bar'},
              children: [
                Div(
                  attributes: {'class': 'cat-inner'},
                  children: [
                    A(
                      attributes: {
                        'expr:class': 'data:view.isSearch and !data:view.search.label ? "cat-link active" : "cat-link"',
                        'expr:href': 'data:blog.homepageUrl + "search"',
                      },
                      children: [Text('ALL')],
                    ),
                    BLoop(
                      values: 'data:labels',
                      varName: 'label',
                      children: [
                        A(
                          attributes: {
                            'class': 'cat-link',
                            'expr:href': 'data:label.url',
                          },
                          children: [BData(value: 'label.name')],
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
