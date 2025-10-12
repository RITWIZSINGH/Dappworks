import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  final String otherUid;
  const ChatsScreen({super.key, required this.otherUid});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // [{uid, text}]

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _messages.add({'uid': 'me', 'text': _controller.text.trim()}));
    _controller.clear();
    // TODO: send via chat service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final m = _messages[i];
              final isMe = m['uid'] == 'me';
              final bubble = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 16),
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['uid']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(m['text']!),
                ]),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [bubble],
                ),
              );
            },
          ),
        ),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(16),
            hintText: 'Leave a message...',
            border: InputBorder.none,
            fillColor: Color(0xB3000000),
            filled: true,
          ),
          onSubmitted: (_) => _send(),
        ),
      ]),
    );
  }
}
