import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/summary.dart';

Future<Summary> getArticleSummaryByTitle(String title) async {
  final http.Client client = http.Client();
  try {
    final Uri url = Uri.https(
      'en.wikipedia.org',
      '/api/rest_v1/page/summary/$title',
    );
    final http.Response response = await client.get(url);
    if (response.statusCode == 200) {
      final payload = json.decode(response.body) as Map<String, Object?>;
      return Summary.fromJson(payload);
    } else {
      throw HttpException(
        '[WikipediaApiClient.getArticleSummaryByTitle] '
        'statusCode=${response.statusCode}, body=${response.body}',
      );
    }
  } on FormatException {
    // todo: log exceptions
    rethrow;
  } finally {
    client.close();
  }
}

Future<Summary> getRandomArticleSummary() async {
  final http.Client client = http.Client();
  try {
    final url = Uri.https(
      'en.wikipedia.org',
      '/api/rest_v1/page/random/summary',
    );
    final response = await client.get(url);
    if (response.statusCode == 200) {
      final Map<String, Object?> payload =
          json.decode(response.body) as Map<String, Object?>;
      return Summary.fromJson(payload);
    } else {
      throw HttpException(
        '[WikipediaApiClient.getRandomArticleSummary] '
        'statusCode=${response.statusCode}, body=${response.body}',
      );
    }
  } on FormatException {
    // todo: log exceptions
    rethrow;
  } finally {
    client.close();
  }
}
