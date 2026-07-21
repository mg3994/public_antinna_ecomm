import 'dart:html';
import 'dart:convert';
import 'parser.dart';

class SchemaResolver {
  static final Map<String, Map<String, dynamic>> _cache = {};
  static final Set<String> _resolving = {};

  /// Scans the entire DOM for ld+json scripts and indexes them by `@id`
  static void scanDocument() {
    final scripts = document.querySelectorAll('script[type="application/ld+json"]');
    for (var s in scripts) {
      final parsed = SchemaParser.parseJSON(s.text);
      if (parsed != null) {
        final id = parsed['@id']?.toString();
        if (id != null && id.isNotEmpty) {
          _cache[id] = parsed;
        }
      }
    }
  }

  /// Recursively resolves an entity by its `@id` reference, keeping track of resolving
  /// IDs to prevent infinite circular reference loops.
  static Future<Map<String, dynamic>> resolve(Map<String, dynamic> entity) async {
    final resolved = Map<String, dynamic>.from(entity);
    final keys = resolved.keys.toList();

    for (var key in keys) {
      final val = resolved[key];
      if (val is Map<String, dynamic>) {
        if (val.containsKey('@id') && val.length == 1) {
          final id = val['@id'].toString();
          final resolvedVal = await resolveId(id);
          if (resolvedVal != null) {
            resolved[key] = resolvedVal;
          }
        } else {
          resolved[key] = await resolve(val);
        }
      } else if (val is List) {
        final resolvedList = [];
        for (var item in val) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey('@id') && item.length == 1) {
              final id = item['@id'].toString();
              final resolvedVal = await resolveId(id);
              if (resolvedVal != null) {
                resolvedList.add(resolvedVal);
              } else {
                resolvedList.add(item);
              }
            } else {
              resolvedList.add(await resolve(item));
            }
          } else {
            resolvedList.add(item);
          }
        }
        resolved[key] = resolvedList;
      }
    }

    return resolved;
  }

  /// Resolves a single `@id` string. Checks cache first, then scans document,
  /// then fetches the referenced URL asynchronously.
  static Future<Map<String, dynamic>?> resolveId(String id) async {
    if (id.isEmpty) return null;

    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    // Try scanning the document if not cached
    scanDocument();
    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    // Avoid infinite recursion for currently resolving IDs
    if (_resolving.contains(id)) {
      return null;
    }

    _resolving.add(id);

    try {
      // Fetch the entity from the external path / URL
      final response = await HttpRequest.getString(id);
      final parsed = SchemaParser.parseJSON(response);
      if (parsed != null) {
        _cache[id] = parsed;
        final fullyResolved = await resolve(parsed);
        _cache[id] = fullyResolved;
        return fullyResolved;
      }
    } catch (e) {
      print("Warning: Failed to fetch external schema reference for $id: $e");
    } finally {
      _resolving.remove(id);
    }

    return null;
  }
}
