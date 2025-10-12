import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/job.dart';
import '../../../state/app_state.dart';
import '../../../utils/formatters.dart';
import 'eth_amount.dart';
import 'tag_chip.dart';

class JobListingCard extends StatelessWidget {
  final Job job;
  const JobListingCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.connectedAccount?.toLowerCase();
    final isOwner = me != null && me == job.owner.toLowerCase();
    final hasBid = me != null && job.bidders.map((e) => e.toLowerCase()).contains(me);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(job.jobTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          EthAmount(ethFixed2(job.prizeEth)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: -6, children: job.tags.map((t) => TagChip(t)).toList()),
          const SizedBox(height: 10),
          Text(job.description),
          const SizedBox(height: 12),
          if (!isOwner && !hasBid)
            ElevatedButton(
              onPressed: () => app.bidForJob(job.id),
              child: const Text('Place Bid'),
            )
          else if (!isOwner && hasBid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
              child: const Text('Your request is pending', style: TextStyle(color: Colors.black87)),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/my-projects'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Manage'),
            ),
        ]),
      ),
    );
  }
}
