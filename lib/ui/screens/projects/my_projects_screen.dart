import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../widgets/delete_job_sheet.dart';
import '../../widgets/payout_sheet.dart';
import '../../widgets/tag_chip.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: app.myProjects.isEmpty
            ? const Center(child: Text('No Posted Jobs Yet'))
            : ListView.separated(
                itemCount: app.myProjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final job = app.myProjects[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(job.jobTitle, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: job.tags.map((t) => TagChip(t)).toList()),
                        const SizedBox(height: 8),
                        Text(job.description),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: -8, children: [
                          if (job.listed) ...[
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, '/view-bidders', arguments: job.id),
                              child: const Text('View bidders'),
                            ),
                            OutlinedButton(
                              onPressed: () => showModalBottomSheet(context: context, builder: (_) => DeleteJobSheet(jobId: job.id)),
                              child: const Text('Delete'),
                            ),
                          ],
                          if (!job.listed && !job.paidOut) ...[
                            OutlinedButton(
                              onPressed: () => showModalBottomSheet(context: context, builder: (_) => PayoutSheet(jobId: job.id)),
                              child: const Text('Pay'),
                            ),
                          ],
                          if (job.paidOut) const Chip(label: Text('Completed'), avatar: Icon(Icons.check_circle, color: Colors.green)),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
