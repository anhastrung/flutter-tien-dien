import '../models/electric_tier.dart';

double calcPrice(double kwh, List<ElectricTier> tiers) {
  double remain = kwh;
  double total = 0;

  for (final t in tiers) {
    if (remain <= 0) break;
    final range = t.to - t.from + 1;
    final used = remain > range ? range : remain;
    total += used * t.price;
    remain -= used;
  }
  return total;
}
