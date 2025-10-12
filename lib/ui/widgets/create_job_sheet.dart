import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../../utils/validators.dart';
import '../../../utils/formatters.dart';

class CreateJobSheet extends StatefulWidget {
  const CreateJobSheet({super.key});
  @override
  State<CreateJobSheet> createState() => _CreateJobSheetState();
}

class _CreateJobSheetState extends State<CreateJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _prize = TextEditingController();
  final _desc  = TextEditingController();
  final _skill = TextEditingController();
  final List<String> _skills = [];

  void _addSkill() {
    if (_skills.length != 5 && _skill.text.trim().isNotEmpty) {
      setState(() => _skills.add(_skill.text.trim()));
    }
    _skill.clear();
  }

  void _removeSkill(int i) {
    setState(() => _skills.removeAt(i));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _skills.isEmpty) return;
    await context.read<AppState>().addJob(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      tags: _skills,
      prizeEth: _prize.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Create a Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Job Title', hintText: 'e.g., Content writer...'),
                validator: (v) => isNotEmpty(v) ? null : 'Required',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _prize,
                decoration: const InputDecoration(labelText: 'Prize (ETH)', hintText: 'e.g., 0.04'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => isNotEmpty(v) ? null : 'Required',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _skill,
                decoration: InputDecoration(
                  labelText: 'Featured skills (3 - 5)',
                  suffixIcon: _skills.length != 5
                      ? TextButton(onPressed: _addSkill, child: const Text('add'))
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: List.generate(_skills.length, (i) => Chip(
                  label: Text(truncateMiddle(_skills[i])),
                  onDeleted: () => _removeSkill(i),
                )),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'write something beautiful...'),
                maxLines: 4,
                validator: (v) => isNotEmpty(v) ? null : 'Required',
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Create')),
            ]),
          ),
        ),
      ),
    );
  }
}
