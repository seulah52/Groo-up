enum GrowthStage {
  seed, sprout, tree, fruit;

  /// 서버 status / growth_stage 문자열을 안전히 enum으로 변환 (알 수 없으면 seed)
  static GrowthStage parse(String raw) {
    for (final v in GrowthStage.values) {
      if (v.name == raw) return v;
    }
    return GrowthStage.seed;
  }

  String get label {
    switch (this) {
      case GrowthStage.seed:   return '씨앗';
      case GrowthStage.sprout: return '새싹';
      case GrowthStage.tree:   return '나무';
      case GrowthStage.fruit:  return '열매';
    }
  }

  GrowthStage? get next {
    switch (this) {
      case GrowthStage.seed:   return GrowthStage.sprout;
      case GrowthStage.sprout: return GrowthStage.tree;
      case GrowthStage.tree:   return GrowthStage.fruit;
      case GrowthStage.fruit:  return null;
    }
  }
}
