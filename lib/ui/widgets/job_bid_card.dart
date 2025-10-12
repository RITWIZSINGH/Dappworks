import 'package:flutter/material.dart';
import '../../../data/models/job.dart';
import '../../../utils/formatters.dart';
import 'eth_amount.dart';
import 'tag_chip.dart';

class JobBidCard extends StatelessWidget {
  final Job job;
  const JobBidCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
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
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/chats', arguments: job.owner),
            child: const Text('Chat with owner'),
          ),
        ]),
      ),
    );
  }
}
