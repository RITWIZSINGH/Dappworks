import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/bidder.dart';
import '../../../state/app_state.dart';
import '../../../utils/formatters.dart';

class ApplicantCard extends StatelessWidget {
  final Bidder bidder;
  const ApplicantCard({super.key, required this.bidder});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(truncateMiddle(bidder.account)),
          Wrap(spacing: 8, children: [
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/chats', arguments: bidder.account),
              child: const Text('Chat'),
            ),
            ElevatedButton(
              onPressed: () => app.acceptBid(id: bidder.id, jId: bidder.jId, account: bidder.account),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Accept'),
            ),
          ]),
        ]),
      ),
    );
  }
}
