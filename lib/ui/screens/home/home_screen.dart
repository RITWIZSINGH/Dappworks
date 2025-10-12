import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../widgets/app_header.dart';
import '../../widgets/create_job_sheet.dart';
import '../../widgets/job_listing_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: const AppHeader(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreateJobSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app.jobs.isNotEmpty ? 'Job listings' : 'No jobs yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: app.jobs.length,
                itemBuilder: (_, i) => JobListingCard(job: app.jobs[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
