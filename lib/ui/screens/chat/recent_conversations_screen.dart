import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class RecentConversationsScreen extends StatelessWidget {
  const RecentConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire to chatState when you connect CometChat.
    final items = <Map<String, String>>[]; // [{uid, name}]
    return Scaffold(
      appBar: const AppHeader(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          const Text('Your Recent chats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (items.isEmpty) const Text("you don't have any recent chats"),
          ...items.map((c) => ListTile(
                onTap: () => Navigator.pushNamed(context, '/chats', arguments: c['uid']),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c['name'] ?? ''),
              )),
        ]),
      ),
    );
  }
}
