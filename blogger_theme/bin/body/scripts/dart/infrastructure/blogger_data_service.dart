import 'dart:html';
import 'dart:convert';
import '../core/parser.dart';

class BloggerDataService {
  static final BloggerDataService _instance = BloggerDataService._internal();

  BloggerDataService._internal();

  factory BloggerDataService() {
    return _instance;
  }

  Future<Map<String, dynamic>> fetchFeedData({
    int maxResults = 50,
    int startIndex = 1,
    dynamic labels = '',
    String searchQuery = '',
  }) async {
    var labelPath = '';

    if (labels != null) {
      final labelsList = labels is List ? labels : [labels.toString()];
      final filteredLabels = labelsList.where((l) => l.toString().trim().isNotEmpty).toList();
      if (filteredLabels.isNotEmpty) {
        final encodedLabels = filteredLabels.map((l) => Uri.encodeComponent(l.toString().trim())).join(',');
        labelPath = '/-/$encodedLabels';
      }
    }

    var feedUrl = '/feeds/posts/default$labelPath?alt=json&max-results=$maxResults&start-index=$startIndex';

    if (searchQuery.isNotEmpty) {
      feedUrl += '&q=${Uri.encodeComponent(searchQuery)}';
    }

    try {
      final response = await HttpRequest.getString(feedUrl);
      final data = json.decode(response) as Map<String, dynamic>;
      final feed = data['feed'] as Map<String, dynamic>? ?? {};
      final entries = feed['entry'] as List<dynamic>? ?? [];
      final totalResultsStr = feed['openSearch\$totalResults']?['\$t']?.toString() ?? '0';

      return {
        'entries': entries,
        'totalResults': int.tryParse(totalResultsStr) ?? 0,
      };
    } catch (e) {
      print("Failed to fetch Blogger feed: $e");
      return {'entries': <dynamic>[], 'totalResults': 0};
    }
  }

  Map<String, dynamic>? extractSchemaFromEntry(Map<String, dynamic> entry) {
    final content = entry['content']?['\$t']?.toString() ?? '';
    return SchemaParser.parseJSON(content);
  }

  Future<List<String>> fetchSearchSuggestions(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final labelRegex = RegExp(r'label:([^|\s]+)', caseSensitive: false);
      final labels = <String>[];
      final matches = labelRegex.allMatches(query);

      for (var match in matches) {
        final val = match.group(1);
        if (val != null) {
          labels.add(Uri.decodeComponent(val.trim().replaceAll('_', ' ')));
        }
      }

      var labelPrefix = '';
      if (matches.isNotEmpty) {
        final lastMatch = matches.last;
        labelPrefix = query.substring(0, lastMatch.start + lastMatch.group(0)!.length).trim() + ' ';
        if (query.trim().endsWith('|')) {
          labelPrefix = query.trim() + ' ';
        }
      }

      final cleanedQuery = query.replaceAll(labelRegex, '').replaceAll('|', '').trim();
      final results = await fetchFeedData(
        maxResults: 50,
        startIndex: 1,
        labels: labels,
        searchQuery: cleanedQuery,
      );

      final entries = results['entries'] as List<dynamic>? ?? [];
      final suggestions = <String>{};
      final normalizedKeyword = cleanedQuery.toLowerCase();

      for (var entryVal in entries) {
        if (entryVal is Map<String, dynamic>) {
          final title = entryVal['title']?['\$t']?.toString() ?? '';
          if (normalizedKeyword.isEmpty || title.toLowerCase().contains(normalizedKeyword)) {
            suggestions.add('$labelPrefix$title'.trim());
          }

          final data = extractSchemaFromEntry(entryVal);
          if (data != null) {
            final keywords = data['keywords'];
            if (keywords != null && keywords is String) {
              for (var k in keywords.split(',')) {
                final trimmed = k.trim();
                if (normalizedKeyword.isEmpty || trimmed.toLowerCase().contains(normalizedKeyword)) {
                  suggestions.add('$labelPrefix$trimmed'.trim());
                }
              }
            }

            final name = data['name']?.toString() ?? '';
            if (name.isNotEmpty && (normalizedKeyword.isEmpty || name.toLowerCase().contains(normalizedKeyword))) {
              suggestions.add('$labelPrefix$name'.trim());
            }
          }
        }
      }

      return suggestions.toList().take(10).toList();
    } catch (e) {
      print("Failed to fetch suggestions: $e");
      return [];
    }
  }
}
