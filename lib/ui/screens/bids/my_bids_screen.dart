import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../widgets/job_bid_card.dart';

class MyBidsScreen extends StatelessWidget {
  const MyBidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Bids')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(app.myBidJobs.isNotEmpty ? 'Jobs You Applied For' : "You Haven't Bid on Any Jobs Yet.",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: app.myBidJobs.length,
              itemBuilder: (_, i) => JobBidCard(job: app.myBidJobs[i]),
            ),
          ),
        ]),
      ),
    );
  }
}
