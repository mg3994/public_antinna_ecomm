import 'dart:html';

class FeedService {
  static String getFeedUrl() {
    final path = window.location.pathname ?? '';
    var feedUrl = '/feeds/posts/default?alt=json&max-results=25';
    if (path.contains('/search/label/')) {
      final label = path.split('/').last.split('?').first;
      feedUrl = '/feeds/posts/default/-/$label?alt=json&max-results=25';
    }
    return feedUrl;
  }

  static Future<String> fetchFeed(String url) {
    return HttpRequest.getString(url);
  }
}
