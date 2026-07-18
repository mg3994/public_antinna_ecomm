import 'package:blogger_theme/blogger_theme.dart';

final title_head = Title(
  children: [
    BData(value: 'blog.title.escaped'),
    BIf(cond: Data.isArchive, children: [
      Text(":"),
      BData(value: "blog.pageName"),
      Text("(", escape: false),
      BData(value: "messages.archive"),
      Text(")"),
      BElseIf(
        cond: "data:view.isLabelSearch",
      ),
      Text(":"),
      BData(value: "blog.pageName"),
      Text("("),
      BData(value: "messages.labels"),
      Text(")"),
      BElseIf(
        cond: "data:view.isSearch",
      ),
      Text(":"),
      BData(value: "messages.search"),
    ])
  ],
);
