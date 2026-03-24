import 'package:equatable/equatable.dart';
import 'growth_stage.dart';

class GrooEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final int completionRate;    // 0~100
  final GrowthStage growthStage;
  final String healthStatus;   // 'red' | 'orange' | 'green' | 'gold'
  final int healthScore;       // 0~100
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final bool isArchived;

  const GrooEntity({
    required this.id, required this.userId, required this.title,
    this.description, this.category,
    required this.completionRate,
    required this.growthStage, required this.healthStatus,
    required this.healthScore, required this.lastActivityAt,
    required this.createdAt, this.isArchived = false,
  });

  GrooEntity copyWith({
    int? completionRate,
    GrowthStage? growthStage, String? healthStatus,
    int? healthScore, DateTime? lastActivityAt,
  }) => GrooEntity(
    id: id, userId: userId, title: title,
    description: description, category: category,
    completionRate: completionRate ?? this.completionRate,
    growthStage: growthStage ?? this.growthStage,
    healthStatus: healthStatus ?? this.healthStatus,
    healthScore: healthScore ?? this.healthScore,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    createdAt: createdAt, isArchived: isArchived,
  );

  @override
  List<Object?> get props =>
      [id, completionRate, growthStage, healthStatus, healthScore];
}
