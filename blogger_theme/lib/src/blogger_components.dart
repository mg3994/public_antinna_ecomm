import 'core.dart';

/// A Blogger section container, mapped to the `b:section` template tag.
class BSection extends DomComponent {
  final String id;
  final String? className;
  final int? maxwidgets;
  final bool? showaddelement;
  final String? growth;
  final bool? preferred;

  BSection({
    required this.id,
    super.children,
    this.className,
    this.maxwidgets,
    this.showaddelement,
    this.growth,
    this.preferred,
  }) : super(
         'b:section',
         attributes: {
           'id': id,
           'class': ?className,
           'maxwidgets': ?maxwidgets?.toString(),
           if (showaddelement != null)
             'showaddelement': showaddelement ? 'yes' : 'no',
           'growth': ?growth,
           'preferred': ?preferred?.toString(),
         },
       );
}

/// Marks where widget settings can be declared inside a Blogger layout.
class BWidgetSettings extends DomComponent {
  const BWidgetSettings({super.children}) : super('b:widget-settings');
}

/// Represents a named widget setting element.
class BWidgetSetting extends DomComponent {
  final String name;

  BWidgetSetting({required this.name, super.children})
    : super('b:widget-setting', attributes: {'name': name});
}

/// Models a Blogger widget definition in the template.
class BWidget extends DomComponent {
  final String id;
  final String type;
  final String? title;
  final bool? locked;
  final String? pageType;
  final String? mobile;
  final int? version;
  final bool? isVisible;

  BWidget({
    required this.id,
    required this.type,
    this.title,
    this.locked,
    this.pageType,
    this.mobile,
    this.version,
    this.isVisible,
    super.children,
  }) : super(
         'b:widget',
         attributes: {
           'id': id,
           'type': type,
           'title': ?title,
           'locked': ?locked?.toString(),
           'pageType': ?pageType,
           'mobile': ?mobile,
           'version': ?version?.toString(),
           'visible': ?isVisible?.toString(),
         },
       );
}

/// Renders a conditional `b:if` block in Blogger templates.
class BIf extends DomComponent {
  final String cond;

  BIf({required this.cond, super.children})
    : super('b:if', attributes: {'cond': cond});
}

/// Renders a conditional `b:elseif` branch inside a `b:if` block.
class BElseIf extends DomComponent {
  final String cond;

  BElseIf({required this.cond}) : super('b:elseif', attributes: {'cond': cond});

  @override
  Iterable<Component> build() => [];
}

/// Renders an `b:else` branch for conditional template logic.
class BElse extends DomComponent {
  const BElse() : super('b:else');
  @override
  Iterable<Component> build() => [];
}

/// Defines a `b:arg` attribute with either a static or expression value.
class BArg extends DomComponent {
  final String name;
  final String? value;
  final String? exprValue;

  BArg({required this.name, this.value, this.exprValue})
    : super(
        'b:arg',
        attributes: {'name': name, 'value': ?value, 'expr:value': ?exprValue},
      );

  @override
  Iterable<Component> build() => [];
}

/// Renders a Blogger loop block using `b:loop`.
class BLoop extends DomComponent {
  final String values;
  final String varName;
  final String? index;

  BLoop({
    required this.values,
    required this.varName,
    this.index,
    super.children,
  }) : super(
         'b:loop',
         attributes: {'values': values, 'var': varName, 'index': ?index},
       );
}

/// Writes a Blogger `data:` node with the provided value.
class BData extends DomComponent {
  final String value;

  const BData({required this.value}) : super('data:$value');

  @override
  Iterable<Component> build() => []; // data tags are self-closing leaf nodes
}

/// Builds a Blogger template skin block with optional CSS variables.
class BSkin extends Component {
  final String css;
  final List<dynamic>? variables; // List of BVariable or BGroup
  final bool useStyleTag; // kept for future not in use

  const BSkin(
    this.css, {
    this.variables,
    this.useStyleTag = false, // kept for future not in use
  });

  @override
  Iterable<Component> build() {
    var sb = StringBuffer();
    if (variables != null && variables!.isNotEmpty) {
      sb.writeln("/*");
      sb.writeln(" * Variable definitions:");
      for (var v in variables!) {
        sb.writeln(v.toString());
      }
      sb.writeln(" */");
    }
    sb.write(css);

    var content = sb.toString();
    if (useStyleTag) {
      content = "<style type='text/css'>\n$content\n</style>";
    }

    return [
      XmlComment('prettier-ignore'),
      DomComponent('b:skin', children: [RawText('<![CDATA[\n$content\n]]>')]),
    ];
  }
}

/// Includes a Blogger template fragment by name.
class BInclude extends DomComponent {
  final String name;
  final String? data;
  final String? cond;

  BInclude({required this.name, this.data, this.cond})
    : super(
        'b:include',
        attributes: {'name': name, 'data': ?data, 'cond': ?cond},
      );
}

/// Defines a named includable fragment for later use.
class BIncludable extends DomComponent {
  final String id;
  final String? varName;

  BIncludable({required this.id, this.varName, super.children})
    : super('b:includable', attributes: {'id': id, 'var': ?varName});
}

/// Adds a conditional attribute entry using Blogger's `b:attr` tag.
class BAttr extends DomComponent {
  final String? cond;
  final String name;
  final String value;
  final String? exprValue;

  BAttr({this.cond, required this.name, required this.value, this.exprValue})
    : super(
        'b:attr',
        attributes: {
          'name': name,
          'value': value,
          'expr:value': ?exprValue,
          'cond': ?cond,
        },
      );
  @override
  Iterable<Component> build() => [];
}

/// Adds a conditional CSS class via Blogger's `b:class` tag.
class BClass extends DomComponent {
  final String name;
  final String cond;

  BClass({required this.name, required this.cond})
    : super('b:class', attributes: {'name': name, 'cond': cond});

  @override
  Iterable<Component> build() => [];
}

/// Creates a dynamic HTML tag using Blogger template helper syntax.
class BTag extends DomComponent {
  final String? name; //either nae or expr:name is required
  final Map<String, String>? attributesz;
  final String? cond;

  BTag({this.name, this.attributesz, this.cond, super.children})
    : super(
        'b:tag',
        attributes: {'name': ?name, ...?attributesz, 'cond': ?cond},
      );
}

/// Evaluates an expression and renders the result in the template.
class BEval extends DomComponent {
  final String expr;

  BEval({required this.expr}) : super('b:eval', attributes: {'expr': expr});

  @override
  Iterable<Component> build() => [];
}

/// Sets a local variable using Blogger's `b:with` helper.
class BWith extends DomComponent {
  final String varName;
  final String value;

  BWith({required this.varName, required this.value, super.children})
    : super('b:with', attributes: {'var': varName, 'value': value});
}

/// Renders a Blogger switch block.
class BSwitch extends DomComponent {
  final String varName;

  BSwitch({required this.varName, super.children})
    : super('b:switch', attributes: {'var': varName});
}

/// Creates a case branch inside a Blogger `b:switch` block.
class BCase extends DomComponent {
  final String value;

  BCase({required this.value, super.children})
    : super('b:case', attributes: {'value': value});
}

/// Represents the default branch of a `b:switch` block.
class BDefault extends DomComponent {
  const BDefault({super.children}) : super('b:default');
}

/// Defines a translatable Blogger message block.
class BMessage extends DomComponent {
  final String name;

  BMessage({required this.name, super.children})
    : super('b:message', attributes: {'name': name});
}

/// Describes a template variable for Blogger skin or configuration metadata.
class BVariable {
  final String name;
  final String description;
  final String type;
  final String defaultValue;
  final String? value;

  const BVariable({
    required this.name,
    required this.description,
    required this.type,
    required this.defaultValue,
    this.value,
  });

  @override
  String toString() {
    return " <Variable name=\"$name\" description=\"$description\" type=\"$type\" default=\"$defaultValue\"${value != null ? " value=\"$value\"" : ""}/>";
  }
}

/// Groups multiple [BVariable] definitions for use in a Blogger skin.
class BGroup {
  final String description;
  final String? selector;
  final List<BVariable> variables;

  const BGroup({
    required this.description,
    this.selector,
    required this.variables,
  });

  @override
  String toString() {
    var sb = StringBuffer();
    sb.writeln(
      " <Group description=\"$description\"${selector != null ? " selector=\"$selector\"" : ""}>",
    );
    for (var v in variables) {
      sb.writeln(v.toString());
    }
    sb.write(" </Group>");
    return sb.toString();
  }
}

/// Emits a Blogger comment node.
class BComment extends DomComponent {
  const BComment({super.children}) : super('b:comment');
}

/// Emits a raw XML comment in the rendered output.
class XmlComment extends Component {
  final String text;

  const XmlComment(this.text);

  @override
  Iterable<Component> build() => [RawText('<!-- $text -->')];
}

/// Wraps raw CSS content in a Blogger `b:template-skin` block.
class BTemplateSkin extends Component {
  final String css;

  const BTemplateSkin(this.css);

  @override
  Iterable<Component> build() => [
    XmlComment('prettier-ignore'),
    DomComponent(
      'b:template-skin',
      children: [RawText('<![CDATA[\n$css\n]]>')],
    ),
  ];
}

/// Declares a Blogger template script dependency.
class BTemplateScript extends DomComponent {
  final String name;
  final String version;
  final bool? async;

  BTemplateScript({required this.name, required this.version, this.async})
    : super(
        'b:template-script',
        attributes: {
          'name': name,
          'version': version,
          'async': ?async?.toString(),
        },
      );

  @override
  Iterable<Component> build() => [];
}

/// Represents a named or expression parameter for template helpers.
class BParam extends DomComponent {
  final String? value;
  final String? exprValue;

  BParam({this.value, this.exprValue})
    : super('b:param', attributes: {'value': ?value, 'expr:value': ?exprValue});

  @override
  Iterable<Component> build() => [];
}

/// Declares a default markup type within the Blogger template.
class BDefaultMarkup extends DomComponent {
  final String type;

  BDefaultMarkup({required this.type, super.children})
    : super('b:defaultmarkup', attributes: {'type': type});
}

/// Container for multiple default markup declarations.
class BDefaultMarkups extends DomComponent {
  const BDefaultMarkups({super.children}) : super('b:defaultmarkups');
}
