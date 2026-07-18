import 'package:blogger_theme/blogger_theme.dart';

final cookieEUScript = Script(
  childrenz: [
    Text('\n  cookieOptions = {\n '),
    Text('close:" Got it! ",\n'),
    Text('learn: "Privacy Policy",\n'),
    Text('link: "'),
    // BData(value: 'blog.canonicalHomepageUrl'),
    Text('https://policies.google.com/technologies/cookies"\n  };\n'),

    // Text('p/privacy.html"\n  };\n'),
  ],
);
