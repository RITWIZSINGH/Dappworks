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
  final _desc = TextEditingController();
  final _skill = TextEditingController();
  final List<String> _skills = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _title.dispose();
    _prize.dispose();
    _desc.dispose();
    _skill.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skill.text.trim();
    if (_skills.length < 5 && skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skill.clear();
    }
  }

  void _removeSkill(int i) {
    setState(() => _skills.removeAt(i));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one skill'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Convert skills list to comma-separated string
      final tagsString = _skills.join(',');
      
      await context.read<AppState>().addJob(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        tags: _skills,
        prizeEth: _prize.text.trim(),
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Post a New Job',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Job Title
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      labelText: 'Job Title',
                      hintText: 'e.g., Build a React Dashboard',
                      prefixIcon: const Icon(Icons.title, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    validator: (v) => isNotEmpty(v) ? null : 'Title is required',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Prize
                  TextFormField(
                    controller: _prize,
                    decoration: InputDecoration(
                      labelText: 'Prize Amount',
                      hintText: '0.05',
                      prefixIcon: const Icon(Icons.currency_bitcoin, size: 20),
                      suffixText: 'ETH',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (!isNotEmpty(v)) return 'Prize is required';
                      final num? val = double.tryParse(v!);
                      if (val == null || val <= 0) return 'Enter valid amount';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Skills
                  TextFormField(
                    controller: _skill,
                    decoration: InputDecoration(
                      labelText: 'Required Skills',
                      hintText: 'Add skill and press + button',
                      prefixIcon: const Icon(Icons.code, size: 20),
                      suffixIcon: _skills.length < 5
                          ? IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: _addSkill,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      helperText: '${_skills.length}/5 skills added',
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                    textInputAction: TextInputAction.done,
                  ),
                  
                  if (_skills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_skills.length, (i) {
                        return Chip(
                          label: Text(_skills[i]),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeSkill(i),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _desc,
                    decoration: InputDecoration(
                      labelText: 'Job Description',
                      hintText: 'Describe the job requirements...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.description, size: 20),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (v) => isNotEmpty(v) ? null : 'Description is required',
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Post Job',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}