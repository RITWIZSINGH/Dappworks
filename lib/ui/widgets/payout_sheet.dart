import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';

class PayoutSheet extends StatelessWidget {
  final int jobId;
  const PayoutSheet({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.attach_money, color: Colors.blue, size: 36),
          const SizedBox(height: 6),
          const Text("Are you sure you want to initiate this payment?", textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async { await app.payout(jobId); if (context.mounted) Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Proceed'),
            ),
          ]),
        ]),
      ),
    );
  }
}
