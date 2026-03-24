/// Resolves the effective queue no-show margin in minutes.
class EffectiveTimeMarginResolver {
  const EffectiveTimeMarginResolver();

  static const int fallbackMinutes = 2;

  int resolve({required int? timeMarginMinutes}) {
    if (timeMarginMinutes == null) {
      return fallbackMinutes;
    }

    if (timeMarginMinutes < 0 || timeMarginMinutes > 60) {
      return fallbackMinutes;
    }

    return timeMarginMinutes;
  }
}
