import 'package:flutter/material.dart';
class EthAmount extends StatelessWidget {
  final String value;
  const EthAmount(this.value, {super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.currency_bitcoin, size: 16), // simple icon stand-in
      const SizedBox(width: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]);
  }
}
