class SearchResult {
  final String title;
  final String url;
  SearchResult({required this.title, required this.url});
}

class SearchResults(this.results, {this.searchTerm}) {
  final List<SearchResult> results;
  final String? searchTerm;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    for (final SearchResult result in results) {
      buffer.write('${result.url} \n');
    }
    return '\nSearchResults for $searchTerm: \n$buffer';
  }

  static SearchResults fromJson(List<Object?> payload) {
    if (payload case [
      String searchTerm,
      Iterable articleTitles,
      Iterable _,
      Iterable urls,
    ]) {
      final List titlesList = articleTitles.toList();
      final List urlList = urls.toList();
      final results = [
        for (final (idx, title) in titlesList.indexed)
          SearchResult(title: title, url: urlList[idx]),
      ];
      return .new(results, searchTerm: searchTerm);
    }

    throw FormatException('Could not deserialize SearchResults, json=$payload');
  }
}
