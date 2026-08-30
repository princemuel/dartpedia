import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/search_results.dart';

Future<SearchResults> search(String searchTerm) async {
  final client = http.Client();
  try {
    final Uri url = Uri.https(
      'en.wikipedia.org',
      '/w/api.php',
      <String, Object?>{
        'action': 'opensearch',
        'format': 'json',
        'search': searchTerm,
      },
    );
    final response = await client.get(url);

    if (response.statusCode != 200) {
      throw HttpException(
        '[WikipediaApiClient.search] '
        'statusCode=${response.statusCode}, '
        'body=${response.body}',
      );
    }

    final payload = json.decode(response.body) as List<Object?>;
    return SearchResults.fromJson(payload);
  } on FormatException {
    rethrow;
  } finally {
    client.close();
  }
}
