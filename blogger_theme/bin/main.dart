import 'dart:convert';
import 'dart:io';

import 'package:blogger_theme/blogger_theme.dart';
import 'head/head.dart';
import 'body/body.dart';

Future<void> fetchAntinnaEngine() async {
  print('Fetching latest Antinna Engine from stable_backups_ecomm releases...');
  final url = Uri.parse(
    'https://github.com/mg3994/antinna-blogger-engine/releases/latest/download/antinna-engine.iife.js',
  );
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode == 200) {
      final bytes = await response.fold<List<int>>([], (p, e) => p..addAll(e));
      final jsContent = utf8.decode(bytes);
      final jsContentClean = jsContent.replaceAll(
        '"""',
        '\"\"\"',
      ); // Clean up any triple quotes

      final dartContent =
          '''import 'package:blogger_theme/blogger_theme.dart';

final antinna_engine_script = Script(
  type: 'module',
  contentInCDATA: true,
  content: r"""$jsContentClean""",
);
''';
      final file = File('bin/body/scripts/antinna_engine.dart');
      file.createSync(recursive: true);
      file.writeAsStringSync(dartContent);
      print(
        'Successfully fetched and updated bin/body/scripts/antinna_engine.dart!',
      );
    } else {
      print(
        'Warning: Failed to fetch Antinna Engine (Status: ${response.statusCode}). Using cached/existing file.',
      );
    }
  } catch (e) {
    print(
      'Warning: Network error fetching Antinna Engine: $e. Using cached/existing file.',
    );
  } finally {
    client.close();
  }
}

void main(List<String> args) async {
  // 1. Generation Pass: Skips the network request and compiles the XML template
  if (args.contains('--generate-only')) {
    var theme = BloggerTheme(head: [BloggerHead()], body: [BloggerBody()]);
    final xml = theme.generate();
    final outputFile = File('build/blogger/theme.xml');
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync(xml);

    print('Wrote generated theme to ${outputFile.path}');
    return;
  }

  // 2. Fetch Pass: Downloads the asset and writes the Dart file directly to disk
  await fetchAntinnaEngine();

  // 3. Compilation Pass: Re-spawns this script instantly in a clean instance
  print('Compiling theme with fresh engine content...');
  final scriptPath = Platform.script.isScheme('file')
      ? Platform.script.toFilePath()
      : 'bin/main.dart';

  final result = await Process.run('dart', [scriptPath, '--generate-only']);

  // Forward compilation and generation logs seamlessly to your console output
  if (result.stdout.toString().isNotEmpty) stdout.write(result.stdout);
  if (result.stderr.toString().isNotEmpty) stderr.write(result.stderr);
}
