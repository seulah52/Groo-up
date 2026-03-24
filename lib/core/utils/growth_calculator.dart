abstract final class GrowthCalculator {
  static const int greenThreshold  = 70;
  static const int orangeThreshold = 40;
  static const int decayPerDay     = 5;

  static String calculateHealthStatus(int score) {
    if (score >= greenThreshold)  return 'green';
    if (score >= orangeThreshold) return 'orange';
    return 'red';
  }

  static int calculateDecay(DateTime lastActivity) {
    final days = DateTime.now().difference(lastActivity).inDays;
    return (days * decayPerDay).clamp(0, 100);
  }

  static int applyDecay(int currentScore, DateTime lastActivity) {
    return (currentScore - calculateDecay(lastActivity)).clamp(0, 100);
  }
}
