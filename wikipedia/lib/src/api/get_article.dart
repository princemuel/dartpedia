import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/article.dart';

Future<List<Article>> getArticleByTitle(String title) async {
  final client = http.Client();
  try {
    final url = Uri.https('en.wikipedia.org', '/w/api.php', <String, Object?>{
      // order matters - explaintext must come after prop
      'action': 'query',
      'format': 'json',
      'titles': title.trim(),
      'prop': 'extracts',
      'explaintext': '',
    });
    final http.Response response = await client.get(url);
    if (response.statusCode == 200) {
      final payload = json.decode(response.body) as Map<String, Object?>;
      return Article.listFromJson(payload);
    } else {
      throw HttpException(
        '[WikipediaApiClient.getArticleByTitle] '
        'statusCode=${response.statusCode}, '
        'body=${response.body}',
      );
    }
  } on FormatException {
    // TODO: log
    rethrow;
  } finally {
    client.close();
  }
}
