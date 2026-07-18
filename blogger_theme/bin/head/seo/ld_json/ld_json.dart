import 'package:blogger_theme/blogger_theme.dart';

final ld_script_Schemas = [
  ld_webSiteSchema,
  ld_breadcrumbSchema,
  ld_localBusinessSchema,
  ld_professionalServiceSchema,
  ld_projectSchema
];

// 1. WebSite Schema (Homepage only condition)
final ld_webSiteSchema = BIf(
  cond: 'data:view.isHomepage',
  children: [
    Script(
      type: "application/ld+json",
      // Assuming attributes can be passed, otherwise add your framework's type parameter
      childrenz: [
        Text('\n{\n'
            '  "@context": "http://schema.org",\n'
            '  "@type": "WebSite",\n'
            '  "name": "'),
        BData(value: 'blog.title'),
        Text('",\n'
            '  "description": "'),
        BData(value: 'view.description.escaped'),
        Text('",\n'
            '  "url": "'),
        BData(value: 'blog.canonicalHomepageUrl'),
        Text('",\n'
            '  "potentialAction": {\n'
            '    "@type": "SearchAction",\n'
            '    "target": "'),
        BData(value: 'blog.canonicalHomepageUrl'),
        Text('search?q={search_term_string}",\n'
            '    "query-input": "required name=search_term_string"\n'
            '  }\n'
            '}\n'),
      ],
    ),
  ],
);

// 2. BreadcrumbList Schema
final ld_breadcrumbSchema = Script(
  type: "application/ld+json",
  childrenz: [
    Text('\n{\n'
        '  "@context": "http://schema.org",\n'
        '  "@type": "BreadcrumbList",\n'
        '  "@id": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('",\n'
        '  "name": "'),
    BData(value: 'blog.title'),
    Text('",\n'
        '  "itemListElement": [\n'
        '    {\n'
        '      "@type": "ListItem",\n'
        '      "position": 1,\n'
        '      "name": "Home",\n'
        '      "item": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('"\n'
        '    },\n'
        '    {\n'
        '      "@type": "ListItem",\n'
        '      "position": 2,\n'
        '      "name": "About",\n'
        '      "item": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('#about"\n'
        '    },\n'
        '    {\n'
        '      "@type": "ListItem",\n'
        '      "position": 3,\n'
        '      "name": "Contact Us",\n'
        '      "item": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('#contact"\n'
        '    }\n'
        '  ]\n'
        '}\n'),
  ],
);

// 3. LocalBusiness Schema
final ld_localBusinessSchema = Script(
  type: "application/ld+json",
  childrenz: [
    Text('\n{\n'
        '  "@context": "https://schema.org",\n'
        '  "@type": "LocalBusiness",\n'
        '  "name": "'),
    BData(value: 'blog.title'),
    Text('",\n'
        '  "url": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('",\n'
        '  "logo": "'),
    BData(value: 'blog.blogspotFaviconUrl'),
    Text('",\n'
        '  "image": "'),
    BData(value: 'blog.blogspotFaviconUrl'),
    Text('",\n'
        '  "sameAs": [\n'
        '    "https://www.facebook.com/profile.php?id=100082961891641",\n'
        '    "https://www.youtube.com/@Antinna",\n'
        '    "https://www.instagram.com/antinna.yt",\n'
        '    "https://github.com/antinna",\n'
        '    "https://play.google.com/store/apps/dev?id=7417258411166270372"\n'
        '  ],\n'
        '  "contactPoint": {\n'
        '    "@type": "ContactPoint",\n'
        '    "telephone": "+918607573994",\n'
        '    "contactType": "customer service",\n'
        '    "email": "contact@antinna.in",\n'
        '    "availableLanguage": ["en", "hi"]\n'
        '  }\n'
        '}\n'),
  ],
);

// 4. ProfessionalService Schema
final ld_professionalServiceSchema = Script(
  type: "application/ld+json",
  childrenz: [
    Text('\n{\n'
        '  "@context": "https://schema.org",\n'
        '  "@type": "ProfessionalService",\n'
        '  "name": "'),
    BData(value: 'blog.title'),
    Text('",\n'
        '  "image": "'),
    BData(value: 'blog.blogspotFaviconUrl'),
    Text('",\n'
        '  "@id": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('",\n'
        '  "url": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('",\n'
        '  "telephone": "+918607573994",\n'
        '  "priceRange": "\$\$",\n'
        '  "address": {\n'
        '    "@type": "PostalAddress",\n'
        '    "streetAddress": "H.No. 42, Village:- Todi",\n'
        '    "addressLocality": "Charkhi Dadri",\n'
        '    "addressRegion": "Haryana",\n'
        '    "postalCode": "127310",\n'
        '    "addressCountry": "IN"\n'
        '  },\n'
        '  "geo": {\n'
        '    "@type": "GeoCoordinates",\n'
        '    "latitude": 28.527867,\n'
        '    "longitude": 76.083600\n'
        '  },\n'
        '  "openingHoursSpecification": {\n'
        '    "@type": "OpeningHoursSpecification",\n'
        '    "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],\n'
        '    "opens": "00:00",\n'
        '    "closes": "23:59"\n'
        '  },\n'
        '  "sameAs": [\n'
        '    "https://www.facebook.com/profile.php?id=100082961891641",\n'
        '    "https://www.instagram.com/antinna.yt/",\n'
        '    "https://youtube.com/antinna",\n'
        '    "https://github.com/antinna",\n'
        '    "https://play.google.com/store/apps/dev?id=7417258411166270372",\n'
        '    "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('"\n'
        '  ]\n'
        '}\n'),
  ],
);

// 5. Project Schema (Truncated list of countries for code cleanliness)
final ld_projectSchema = Script(
  type: "application/ld+json",
  childrenz: [
    Text('\n{\n'
        '  "@context": "https://schema.org",\n'
        '  "@type": "Project",\n'
        '  "name": "'),
    BData(value: 'blog.title'),
    Text('",\n'
        '  "url": "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('",\n'
        '  "logo": "'),
    BData(value: 'blog.blogspotFaviconUrl'),
    Text('",\n'
        '  "contactPoint": [\n'
        '    {\n'
        '      "@type": "ContactPoint",\n'
        '      "telephone": "+918607573994",\n'
        '      "contactType": "Technical Support",\n'
        '      "areaServed": ["US","GB","CA","AF","155","039","154","151","150","145","034","035","030","143","142","419","015","002","ZM","YE","EH","ZW","WF","VN","VE","AX","AL","DZ","AS","AD","AO","AQ","AI","AG","AW","AM","AR","AT","AU","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT","BO","BQ","BA","BW","VA","VU","UZ","UY","UM","AE","UA","TV","VI","UG","TC","TT","TN","TR","TM","TG","TK","TO","TH","TZ","TJ","TW","CH","SY","SE","BR","BV","IO","VG","BN","BG","BF","BI","KH","CM","CV","KY","CF","TD","CL","CX","CN","CC","CO","KM","CK","HR","CR","CU","CW","CY","CZ","CD","DK","DJ","DM","DO","TL","EG","SV","EC","GQ","EE","ER","ET","FK","FO","FJ","FI","GF","FR","PF","TF","GA","GM","SZ","SR","SJ","SD","SS","ES","LK","KR","GS","ZA","SO","SB","SI","SK","SG","SX","SL","SC","SN","SA","RS","PM","VC","SM","WS","ST","GE","DE","GH","GI","GR","GL","GD","GP","GT","MF","LC","BL","SH","KN","RW","RO","RU","RE","CG","PT","PL","PR","QA","PH","PN","GN","GG","GU","GW","GY","HT","HM","HN","HK","HU","IS","ID","IN","IR","IQ","IE","IM","IT","IL","JP","JO","JM","JE","CI","KW","KG","LA","XK","KI","KE","KZ","LV","LB","LS","LY","LR","LT","LU","LI","PY","PE","PG","PA","PW","PS","PK","NO","OM","MP","KP","NI","NE","NG","NU","NF","NZ","NA","NP","NL","NR","NC","MM","MZ","MS","MN","ME","MA","MD","MC","FM","MX","MR","MU","YT","MQ","MH","MV","ML","MT","MW","MG","MY","MO","MK"],\n'
        '      "availableLanguage": ["en","Gujarati","Hindi","Tamil","Telugu","Urdu","Panjabi"]\n'
        '    },\n'
        '    {\n'
        '      "@type": "ContactPoint",\n'
        '      "telephone": "+918607573994",\n'
        '      "contactType": "customer service",\n'
        '      "areaServed": ["US","GB","CA","AF","155","039","154","151","150","145","034","035","030","143","142","419","015","002","ZM","YE","EH","ZW","WF","VN","VE","AX","AL","DZ","AS","AD","AO","AQ","AI","AG","AW","AM","AR","AT","AU","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT","BO","BQ","BA","BW","VA","VU","UZ","UY","UM","AE","UA","TV","VI","UG","TC","TT","TN","TR","TM","TG","TK","TO","TH","TZ","TJ","TW","CH","SY","SE","BR","BV","IO","VG","BN","BG","BF","BI","KH","CM","CV","KY","CF","TD","CL","CX","CN","CC","CO","KM","CK","HR","CR","CU","CW","CY","CZ","CD","DK","DJ","DM","DO","TL","EG","SV","EC","GQ","EE","ER","ET","FK","FO","FJ","FI","GF","FR","PF","TF","GA","GM","SZ","SR","SJ","SD","SS","ES","LK","KR","GS","ZA","SO","SB","SI","SK","SG","SX","SL","SC","SN","SA","RS","PM","VC","SM","WS","ST","GE","DE","GH","GI","GR","GL","GD","GP","GT","MF","LC","BL","SH","KN","RW","RO","RU","RE","CG","PT","PL","PR","QA","PH","PN","GN","GG","GU","GW","GY","HT","HM","HN","HK","HU","IS","ID","IN","IR","IQ","IE","IM","IT","IL","JP","JO","JM","JE","CI","KW","KG","LA","XK","KI","KE","KZ","LV","LB","LS","LY","LR","LT","LU","LI","PY","PE","PG","PA","PW","PS","PK","NO","OM","MP","KP","NI","NE","NG","NU","NF","NZ","NA","NP","NL","NR","NC","MM","MZ","MS","MN","ME","MA","MD","MC","FM","MX","MR","MU","YT","MQ","MH","MV","ML","MT","MW","MG","MY","MO","MK"],\n'
        '      "availableLanguage": ["en","Gujarati","Hindi","Tamil","Telugu","Urdu","Panjabi"]\n'
        '    }\n'
        '  ],\n'
        '  "sameAs": [\n'
        '    "https://www.facebook.com/profile.php?id=100082961891641",\n'
        '    "https://www.instagram.com/antinna.yt/",\n'
        '    "https://youtube.com/antinna",\n'
        '    "https://github.com/antinna",\n'
        '    "https://play.google.com/store/apps/dev?id=7417258411166270372",\n'
        '    "'),
    BData(value: 'blog.canonicalHomepageUrl'),
    Text('"\n'
        '  ]\n'
        '}\n'),
  ],
);
