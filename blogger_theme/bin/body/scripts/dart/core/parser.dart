import 'dart:html';
import 'dart:convert';

class SchemaParser {
  static String decodeEntities(String text) {
    final textArea = TextAreaElement()..setInnerHtml(text);
    return textArea.value ?? '';
  }

  /// Parses a text payload which may contain standard JSON-LD script blocks or raw JSON.
  /// Decodes HTML entities, strips comments, and handles both `Map<String, dynamic>` and `List<dynamic>` roots.
  static dynamic parseJSON(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    final regex = RegExp(
      r'<script[^>]*type=["' "'" r']application\/ld\+json["' "'" r'][^>]*>([\s\S]*?)<\/script>',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    final jsonStr = match != null ? match.group(1) : text;

    if (jsonStr == null) return null;

    var decoded = decodeEntities(jsonStr);
    if (decoded.contains('&quot;')) {
      decoded = decodeEntities(decoded);
    }

    try {
      final cleanJson = decoded
          .replaceAll(RegExp(r'\/\*[\s\S]*?\/'), '')
          .replaceAll(RegExp(r'([^\\:]|^)\/\/.*$'), '')
          .trim();
      return json.decode(cleanJson);
    } catch (e) {
      final braceRegex = RegExp(r'\{[\s\S]*\}|\[[\s\S]*\]');
      final braceMatch = braceRegex.firstMatch(decoded);
      if (braceMatch != null) {
        try {
          return json.decode(braceMatch.group(0)!);
        } catch (_) {}
      }
      print("Failed to parse JSON-LD: $e");
      return null;
    }
  }
}
