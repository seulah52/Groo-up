import '../../domain/entities/groo_entity.dart';
import '../../domain/entities/growth_stage.dart';

class GrooModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final int completionRate;
  final String growthStage;
  final String healthStatus;
  final int healthScore;
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final bool isArchived;

  const GrooModel({
    required this.id, required this.userId, required this.title,
    this.description, this.category,
    required this.completionRate,
    required this.growthStage, required this.healthStatus,
    required this.healthScore, required this.lastActivityAt,
    required this.createdAt, this.isArchived = false,
  });

  /// ideas 테이블: growth_stage+health_status 또는 단일 status(또는 seed_red 형식) 모두 수용
  factory GrooModel.fromJson(Map<String, dynamic> json) {
    final (growthRaw, healthRaw) = _parseGrowthAndHealth(json);
    final created = _parseDate(json['created_at']) ?? DateTime.now();
    final lastAct = _parseDate(json['last_activity_at']) ?? created;

    return GrooModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      completionRate: _parseInt(json['completion_rate'], fallback: 0),
      growthStage: growthRaw,
      healthStatus: healthRaw,
      healthScore: _parseInt(json['health_score'], fallback: 100),
      lastActivityAt: lastAct,
      createdAt: created,
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }

  static (String, String) _parseGrowthAndHealth(Map<String, dynamic> json) {
    final explicitGrowth = json['growth_stage'] as String?;
    final explicitHealth = json['health_status'] as String?;
    final status = json['status'] as String?;

    if (explicitGrowth != null && explicitHealth != null) {
      return (explicitGrowth, _normalizeHealth(explicitHealth));
    }
    if (explicitGrowth != null && explicitHealth == null) {
      return (explicitGrowth, _normalizeHealth(_defaultHealthForGrowth(explicitGrowth)));
    }

    if (status != null && status.contains('_')) {
      final parts = status.split('_');
      final g = parts.first;
      final h = parts.length > 1 ? parts.sublist(1).join('_') : 'red';
      return (g, _normalizeHealth(h));
    }

    if (status != null) {
      final g = status;
      final h = explicitHealth ?? _defaultHealthForGrowth(g);
      return (g, _normalizeHealth(h));
    }

    final g = explicitGrowth ?? 'seed';
    final h = explicitHealth ?? _defaultHealthForGrowth(g);
    return (g, _normalizeHealth(h));
  }

  /// 씨앗 단계는 서버에서 health 누락 시 빨강(초기·주의)으로 표시
  static String _defaultHealthForGrowth(String growth) =>
      growth == 'seed' ? 'red' : 'green';

  static String _normalizeHealth(String raw) {
    final r = raw.toLowerCase();
    if (r == 'red' || r == 'orange' || r == 'green' || r == 'gold') return r;
    return 'green';
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.round();
    return fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'user_id': userId, 'title': title,
    'description': description, 'category': category,
    'completion_rate': completionRate,
    'growth_stage': growthStage, 'health_status': healthStatus,
    'health_score': healthScore,
    'last_activity_at': lastActivityAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'is_archived': isArchived,
  };

  GrooEntity toEntity() => GrooEntity(
    id: id, userId: userId, title: title,
    description: description, category: category,
    completionRate: completionRate,
    growthStage: GrowthStage.parse(growthStage),
    healthStatus: healthStatus, healthScore: healthScore,
    lastActivityAt: lastActivityAt, createdAt: createdAt,
    isArchived: isArchived,
  );
}
