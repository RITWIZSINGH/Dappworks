import 'package:flutter/material.dart';
class TagChip extends StatelessWidget {
  final String label;
  const TagChip(this.label, {super.key});
  @override
  Widget build(BuildContext context) =>
      Chip(label: Text(label), backgroundColor: Colors.grey.shade200, visualDensity: VisualDensity.compact);
}
