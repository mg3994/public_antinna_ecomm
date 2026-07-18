import 'dart:io';
import 'package:path/path.dart' as p;
import 'core.dart';

/// Loads a Dart script from disk and compiles it to JavaScript at render time.
///
/// The script source is expected to be a valid Dart file and will be compiled
/// using the Dart SDK before rendering.
class BClientScript extends Component {
  final String scriptPath;
  final bool? contentInCDATA;

  const BClientScript(this.scriptPath, {this.contentInCDATA});

  @override
  Iterable<Component> build() {
    // This will be handled during the rendering process or by a pre-processor.
    // For simplicity, we can make it a DomComponent that we populate later.
    return [_CompiledScript(scriptPath, contentInCDATA: contentInCDATA)];
  }
}

/// Internal helper that compiles a Dart script into a browser-ready JS [script] node.
class _CompiledScript extends DomComponent {
  final String scriptPath;
  final bool? contentInCDATA;

  const _CompiledScript(
    this.scriptPath, {
    this.contentInCDATA,
  }) : super('script', attributes: const {'type': 'text/javascript'});

  @override
  Iterable<Component> build() {
    var jsContent = _compileDartToJs(scriptPath);
    return [
      if (contentInCDATA == true)
        RawText('//<![CDATA[\n$jsContent\n//]]>')
      else
        Text(jsContent),
    ];
  }

  /// Compiles the Dart file at [path] to JavaScript and returns the output.
  String _compileDartToJs(String path) {
    var fullPath = p.absolute(path);
    if (!File(fullPath).existsSync()) {
      return '// Error: Script not found at $fullPath';
    }

    var tempDir = Directory.systemTemp.createTempSync('dart_compile');
    var outFile = p.join(tempDir.path, 'out.js');

    try {
      var result = Process.runSync('dart', [
        'compile',
        'js',
        '-O4',
        fullPath,
        '-o',
        outFile,
      ]);

      if (result.exitCode != 0) {
        return '// Error compiling Dart to JS:\nExit code: ${result.exitCode}\nSTDOUT: ${result.stdout}\nSTDERR: ${result.stderr}';
      }

      return File(outFile).readAsStringSync();
    } finally {
      tempDir.deleteSync(recursive: true); // Keep it for now if debugging
    }
  }
}
