enum InsightCategory { news, stock, paper }

class TrendLogEntity {
  final String id;
  final InsightCategory category;
  final String title;
  final String? summary;
  final String? sourceUrl;
  final String? sourceName;
  final List<String> relevanceTags;
  final DateTime? publishedAt;

  const TrendLogEntity({
    required this.id, required this.category, required this.title,
    this.summary, this.sourceUrl, this.sourceName,
    this.relevanceTags = const [], this.publishedAt,
  });
}
