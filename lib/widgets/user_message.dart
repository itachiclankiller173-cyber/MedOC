import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
  final String text;

  const UserMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 12, left: 50),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }
}
