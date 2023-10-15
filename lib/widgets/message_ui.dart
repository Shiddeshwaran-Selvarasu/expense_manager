import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat.dart';
import '../utils/time_handler.dart';

class MessageUI extends StatefulWidget {
  const MessageUI({required this.message, super.key});

  final Message message;

  @override
  State<MessageUI> createState() => _MessageUIState();
}

class _MessageUIState extends State<MessageUI> {
  final user = FirebaseAuth.instance.currentUser;

  double getCompletion(Message message) {
    double value = 0;
    int total = message.assignees.length;
    for (var assignee in message.assignees) {
      if (assignee.status) value += 1;
    }
    return value / total;
  }

  int getCompletionCount(Message message) {
    int value = 0;
    for (var assignee in message.assignees) {
      if (assignee.status) value += 1;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    bool isSender = widget.message.sender == user!.email;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isSender)
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.message.sender)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserData userData = UserData.fromMap(snapshot.data!.data()!);
                return Text(
                  userData.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        if (widget.message.assignees.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8,right: 8, bottom: 2),
            child: Text(
              widget.message.getPrice(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.message.description ?? '',
          ),
        ),
        if (widget.message.assignees.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.3,
                child: LinearProgressIndicator(
                  value: getCompletion(widget.message),
                ),
              ),
              Text(
                ' ${getCompletionCount(widget.message)}/${widget.message.assignees.length} Paid',
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateTimeHandler.getTimeDiff(
                  widget.message.createdDate.toDate(),
                ),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              const Icon(
                Icons.done,
                size: 13,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
