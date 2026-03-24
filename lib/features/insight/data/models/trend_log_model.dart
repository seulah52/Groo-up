import '../../domain/entities/trend_log_entity.dart';

class TrendLogModel {
  final String id;
  final InsightCategory category;
  final String title;
  final String? summary;
  final String? sourceUrl;
  final String? sourceName;
  final List<String> relevanceTags;
  final DateTime? publishedAt;

  const TrendLogModel({
    required this.id,
    required this.category,
    required this.title,
    this.summary,
    this.sourceUrl,
    this.sourceName,
    this.relevanceTags = const [],
    this.publishedAt,
  });

  factory TrendLogModel.fromJson(Map<String, dynamic> json) {
    final catRaw = json['category'] as String? ?? 'news';
    InsightCategory category = InsightCategory.news;
    for (final c in InsightCategory.values) {
      if (c.name == catRaw) {
        category = c;
        break;
      }
    }
    final tags = (json['relevance_tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final publishedRaw = json['published_at'] as String?;
    return TrendLogModel(
      id: json['id'] as String,
      category: category,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      sourceUrl: json['source_url'] as String?,
      sourceName: json['source_name'] as String?,
      relevanceTags: tags,
      publishedAt:
          publishedRaw != null ? DateTime.tryParse(publishedRaw) : null,
    );
  }

  TrendLogEntity toEntity() => TrendLogEntity(
        id: id,
        category: category,
        title: title,
        summary: summary,
        sourceUrl: sourceUrl,
        sourceName: sourceName,
        relevanceTags: relevanceTags,
        publishedAt: publishedAt,
      );
}
