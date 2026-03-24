import 'package:equatable/equatable.dart';
import 'growth_stage.dart';

class GrooEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final GrowthStage growthStage;
  final String healthStatus;   // 'red' | 'orange' | 'green'
  final int healthScore;       // 0~100
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final bool isArchived;

  const GrooEntity({
    required this.id, required this.userId, required this.title,
    this.description, this.category,
    required this.growthStage, required this.healthStatus,
    required this.healthScore, required this.lastActivityAt,
    required this.createdAt, this.isArchived = false,
  });

  GrooEntity copyWith({
    GrowthStage? growthStage, String? healthStatus,
    int? healthScore, DateTime? lastActivityAt,
  }) => GrooEntity(
    id: id, userId: userId, title: title,
    description: description, category: category,
    growthStage: growthStage ?? this.growthStage,
    healthStatus: healthStatus ?? this.healthStatus,
    healthScore: healthScore ?? this.healthScore,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    createdAt: createdAt, isArchived: isArchived,
  );

  @override
  List<Object?> get props => [id, growthStage, healthStatus, healthScore];
}
