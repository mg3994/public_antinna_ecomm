import 'package:blogger_theme/blogger_theme.dart';
import 'sidebar/sidebar.dart';
import 'app_container/container.dart';
import 'scripts/scripts.dart';
import 'account_settings_modal_backdrop/account_settings_modal_backdrop.dart';
import 'interactive_modals.dart';

class BloggerBody implements Component {
  @override
  Iterable<Component> build() {
    return [
      sidebar_backdrop,
      app_container,
      // Modal pop up
      account_settings_modal_backdrop,

      // Interactive Shopping Bag and Location modals
      cart_modal_backdrop,
      cart_drawer,
      cart_fab_container,
      loc_modal_backdrop,

      //js scripts
      theme_mode_sync_script,
      firebase_and_toast,
      antinna_engine_script,

      ///
      // Script(
      //   type: "module",
      //   src: "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js",
      // ),
      // Script(
      //   type: "module",
      //   src: "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js",
      // ),
      // Script(
      //   type: "module",
      //   src: "https://www.gstatic.com/firebasejs/11.6.1/firebase-messaging.js",
      // ),

      // BClientScript('bin/body/script/main.dart', contentInCDATA: true),
    ];
  }
}
