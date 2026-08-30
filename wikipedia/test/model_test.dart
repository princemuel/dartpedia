import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wikipedia/src/model/article.dart';
import 'package:wikipedia/src/model/search_results.dart';
import 'package:wikipedia/src/model/summary.dart';

const String dartLangSummaryJson = './test/data/dart_lang_summary.json';
const String catExtractJson = './test/data/cat_extract.json';
const String openSearchResponse = './test/data/open_search_response.json';

void main() {
  group('deserialize example JSON responses from wikipedia API', () {
    test('deserialize Dart Programming Language page summary example data from '
        'json file into a Summary object', () async {
      final pageSummaryInput = await File(dartLangSummaryJson).readAsString();
      final pageSummaryMap =
          jsonDecode(pageSummaryInput) as Map<String, Object?>;
      final summary = Summary.fromJson(pageSummaryMap);
      expect(summary.titles.canonical, 'Dart_(programming_language)');
    });

    test('deserialize Cat article example data from json file into '
        'an Article object', () async {
      final articleJson = await File(catExtractJson).readAsString();
      final articleMap = jsonDecode(articleJson) as Map<String, Object?>;
      final articles = Article.listFromJson(articleMap);
      expect(articles.first.title.toLowerCase(), 'cat');
    });

    test('deserialize Open Search results example data from json file '
        'into an SearchResults object', () async {
      final resultsString = await File(openSearchResponse).readAsString();
      final resultsAsList = jsonDecode(resultsString) as List<Object?>;
      final results = SearchResults.fromJson(resultsAsList);
      expect(results.results.length, greaterThan(1));
    });
  });
}
