/// Consistent money display across the app.
String formatGhs(num amount, {bool decimals = false}) {
  if (decimals) {
    return 'GHS ${amount.toStringAsFixed(2)}';
  }
  final v = amount.toDouble();
  if (v == v.roundToDouble()) {
    return 'GHS ${v.toStringAsFixed(0)}';
  }
  return 'GHS ${v.toStringAsFixed(2)}';
}
