import 'package:expense_manager/models/chat.dart';
import 'package:expense_manager/pages/message_detail.dart';
import 'package:expense_manager/widgets/message_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/room.dart';

class MessageTile extends StatefulWidget {
  const MessageTile({super.key, required this.room, required this.message});

  final Message message;
  final Room room;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: widget.message.sender == user!.email ? 100 : 10,
            right: widget.message.sender == user!.email ? 10 : 100),
        alignment: widget.message.sender == user!.email
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Material(
          elevation: 1,
          borderRadius: widget.message.sender == user!.email
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )
              : const BorderRadius.only(
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
          child: Container(
            // margin: widget.message.sender == user!.email
            //     ? const EdgeInsets.only(left: 30)
            //     : const EdgeInsets.only(right: 30),
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
            decoration: BoxDecoration(
              color: widget.message.sender == user!.email
                  ? Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withAlpha(100)
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: widget.message.sender == user!.email
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )
                  : const BorderRadius.only(
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                if (widget.message.assignees.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageDetail(
                        message: widget.message,
                        room: widget.room,
                      ),
                    ),
                  );
                }
              },
              child: MessageUI(
                message: widget.message,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
