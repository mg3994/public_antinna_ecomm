//  <!-- Primary Feed Workspace Window Mount Section -->
//             <main class='scrollable-main-content'>
//                 <b:section class='main-feed-section' id='main-feed-stream' showelement='yes'>
//                 </b:section>
//             </main>

import 'package:blogger_theme/blogger_theme.dart';

final scrollable_main_content = Main(
  attributes: {'class': 'scrollable-main-content'},
  children: [
    BSection(
      className: 'main-feed-section',
      id: 'main-feed-stream',
      showaddelement: true,
      children: [
        // <b:widget id='Text1' for messafges at top
        // ...... work here for future TODO:
      ],
    ),
  ],
);
