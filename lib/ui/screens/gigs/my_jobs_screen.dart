import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../widgets/job_bid_card.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(app.myGigs.isNotEmpty ? 'Assigned Tasks.' : "You Don't Have Any Assigned task.",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: app.myGigs.length,
              itemBuilder: (_, i) => JobBidCard(job: app.myGigs[i]),
            ),
          ),
        ]),
      ),
    );
  }
}
