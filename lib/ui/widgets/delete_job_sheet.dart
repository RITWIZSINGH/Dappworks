import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';

class DeleteJobSheet extends StatelessWidget {
  final int jobId;
  const DeleteJobSheet({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.delete_forever, color: Colors.red, size: 36),
          const SizedBox(height: 6),
          const Text("Are you sure you want to delete this?", textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text("This action can't be undone", style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async { await app.deleteJob(jobId); if (context.mounted) Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Proceed'),
            ),
          ]),
        ]),
      ),
    );
  }
}
