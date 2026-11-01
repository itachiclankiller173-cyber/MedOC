import 'package:flutter/material.dart';

class AIMessage extends StatelessWidget {
  final String text;

  const AIMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.smart_toy, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
