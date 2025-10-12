
String truncateMiddle(String text, {int head = 4, int tail = 4, int max = 11}) {
  if (text.length <= max) return text;
  return '${text.substring(0, head)}...${text.substring(text.length - tail)}';
}

String ethFixed2(String eth) {
  // keep parity with the web that shows 2dp on listing cards
  final n = double.tryParse(eth) ?? 0.0;
  return n.toStringAsFixed(2);
}
