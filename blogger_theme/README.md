# 🚀 blogger_theme

[![pub package](https://img.shields.io/pub/v/blogger_theme.svg?logo=dart&logoColor=white&color=blue)](https://pub.dev/packages/blogger_theme)
[![pub points](https://img.shields.io/pub/points/blogger_theme.svg?logo=dart&logoColor=white)](https://pub.dev/packages/blogger_theme/score)
[![License](https://img.shields.io/github/license/antinna/blogger_theme.svg?color=blue)](https://github.com/antinna/blogger_theme/blob/main/LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/antinna/blogger_theme.svg?logo=github)](https://github.com/antinna/blogger_theme/issues)
[![Sponsor](https://img.shields.io/badge/Sponsor-GitHub%20Sponsors-ff69b4.svg?logo=github-sponsors)](https://github.com/sponsors/manishmg3994)

---

## What is `blogger_theme`?

`blogger_theme` is a lightweight Dart library for generating Blogger (Blogspot) theme XML using a clean, declarative component API inspired by Jaspr.

It removes the need to write raw Blogger template XML by hand and provides reusable Dart components for common Blogger template elements such as `b:section`, `b:widget`, `b:if`, `b:loop`, and `b:skin`.

---

## Features

- **Declarative theme authoring** in Dart using `Component`, `DomComponent`, and `Text`.
- **Pure Dart implementation** with zero runtime dependencies.
- **Safe XML rendering** for Blogger templates, including escaping special characters and filtering XML 1.0 control characters.
- **Blogger-native helpers** for sections, widgets, conditionals, loops, includes, and template fragments.
- **Client script support** with `BClientScript` for Dart-to-JS inline script injection.
- **Flexible theme export** using `BloggerTheme.generate()`.

---

## Installation

Add `blogger_theme` to your `pubspec.yaml`:

```yaml
dependencies:
  blogger_theme: ^3.0.0
```

Or add it directly with:

```bash
dart pub add blogger_theme
```

Run:

```bash
dart pub get
```

---

## References

- Documentation: https://bloggerquickstart.blogspot.com/
- Video tutorials: https://youtube.com/antinna
- Sponsor the project: https://github.com/sponsors/manishmg3994

---

## Quick Start

### 1. Define your layout component

```dart
import 'package:blogger_theme/blogger_theme.dart';

class BlogLayout extends Component {
  const BlogLayout();

  @override
  Iterable<Component> build() => [
        Div(
          attributes: {'class': 'wrapper-pane'},
          children: [
            BSection(
              id: 'header-area',
              className: 'header-section',
              maxwidgets: 1,
              showaddelement: true,
              children: [
                BWidget(
                  id: 'Header1',
                  type: 'Header',
                  title: 'Blog Header Title',
                  locked: true,
                ),
              ],
            ),
            BIf(
              cond: 'data:view.isPost',
              children: [
                Div(
                  attributes: {'class': 'post-item'},
                  children: [BData(value: 'post.body')],
                ),
              ],
            ),
          ],
        ),
      ];
}
```

### 2. Generate Blogger theme XML

```dart
import 'package:blogger_theme/blogger_theme.dart';

void main() {
  final theme = BloggerTheme(
    attributes: {
      'b:responsive': 'true',
      'b:defaultwidgetversion': '2',
      'b:layoutsversion': '3',
    },
    head: [
      Title(children: [Text('Generated Blogger Theme')]),
      BSkin('body { font-family: Arial, sans-serif; }'),
    ],
    body: [const BlogLayout()],
  );

  final xml = theme.generate();
  print(xml);
}
```

---

## API Overview

### Core building blocks

- `Component`
- `DomComponent`
- `Text`
- `RawText`
- `Fragment`
- `Renderer`

### Blogger-specific components

- `BSection`, `BWidget`, `BWidgetSettings`, `BWidgetSetting`
- `BIf`, `BElseIf`, `BElse`
- `BLoop`, `BData`, `BArg`, `BAttr`, `BClass`
- `BInclude`, `BIncludable`, `BTag`, `BEval`
- `BSkin`
- `BClientScript`

### HTML helper components

- Standard HTML wrappers like `Div` plus other helpers in `html_components.dart`

---

## Project Structure

- `lib/blogger_theme.dart` — public exports
- `lib/src/core.dart` — component model and renderer
- `lib/src/blogger_components.dart` — Blogger template helpers
- `lib/src/html_components.dart` — HTML helper components
- `lib/src/client_script.dart` — Dart-to-JS script support
- `lib/src/theme_utility.dart` — theme generation utilities
- `example/main.dart` — sample theme generation entrypoint

---

## Contributing

Contributions are welcome!

- Found a bug? Open an issue: https://github.com/antinna/blogger_theme/issues
- Want to improve the library? Fork the repo and submit a pull request.

---

## License

`blogger_theme` is licensed under the MIT License. See [LICENSE](LICENSE) for details.
