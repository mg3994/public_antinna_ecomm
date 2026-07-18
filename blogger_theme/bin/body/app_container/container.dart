import 'package:blogger_theme/blogger_theme.dart';
import '../sidebar/sidebar.dart';
import '../main_view_wrapper/main_view_wrapper.dart';


final app_container = Div(attributes: {
  'class': 'app-container',
}, children: [
  sidebar_drawer,
  main_view_wrapper,

 
]);
