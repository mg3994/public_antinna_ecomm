import 'package:blogger_theme/blogger_theme.dart';

final themeScript = Script(
  type: 'text/javascript',
  childrenz: [
    Text('(function() {\n'),
    Text("  var cachedTheme = localStorage.getItem('antinna-theme');\n"),
    Text(
        "  var systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;\n"),
    Text('\n'),
    Text(
        "  if (cachedTheme === 'dark' || (!cachedTheme && systemPrefersDark)) {\n"),
    Text("    document.documentElement.classList.add('dark');\n"),
    Text('  } else {\n'),
    Text("    document.documentElement.classList.remove('dark');\n"),
    Text('  }\n'),
    Text('})();\n'),
  ],
);
