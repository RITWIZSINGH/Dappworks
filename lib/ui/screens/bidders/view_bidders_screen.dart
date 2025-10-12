import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../widgets/applicant_card.dart';

class ViewBiddersScreen extends StatefulWidget {
  final int jobId;
  const ViewBiddersScreen({super.key, required this.jobId});

  @override
  State<ViewBiddersScreen> createState() => _ViewBiddersScreenState();
}

class _ViewBiddersScreenState extends State<ViewBiddersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppState>().loadBidders(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final bidders = app.bidders;
    final job = app.currentJob;

    String title;
    if ((bidders).isNotEmpty) {
      title = 'Applicants';
    } else if (job != null && !job.listed) {
      title = 'Position filled';
    } else {
      title = 'No Applicants yet.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bidders')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: bidders.length,
              itemBuilder: (_, i) => ApplicantCard(bidder: bidders[i]),
            ),
          ),
        ]),
      ),
    );
  }
}
