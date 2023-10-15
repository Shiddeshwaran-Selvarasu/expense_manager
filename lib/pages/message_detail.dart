import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/chat.dart';
import 'package:expense_manager/models/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/room.dart';

class MessageDetail extends StatefulWidget {
  const MessageDetail({required this.message, required this.room, super.key});

  final Message message;
  final Room room;

  @override
  State<MessageDetail> createState() => _MessageDetailState();
}

class _MessageDetailState extends State<MessageDetail> {
  final user = FirebaseAuth.instance.currentUser;

  showAlert(bool status, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 25,
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text("Warning"),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Text(
              "Do you want to mark this as ${status ? 'Unpaid' : 'Paid'}?"),
          actionsAlignment: MainAxisAlignment.end,
          elevation: 5,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.message.assignees[index].status = !status;
                  });
                  FirebaseFirestore.instance
                      .collection('rooms/${widget.room.code}/chats')
                      .doc(widget.message.id)
                      .update(widget.message.toMap());
                },
                child: const Text(
                  "Change",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget assigneeCard(Assignee assignee, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(assignee.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = UserData.fromMap(snapshot.data!.data()!);
            return ListTile(
              leading: CircleAvatar(
                foregroundImage: NetworkImage(userData.profileImageUrl),
              ),
              title: Text(
                userData.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(userData.email),
              contentPadding: EdgeInsets.zero,
              trailing: assignee.status
                  ? IconButton(
                      onPressed: () {
                        if(widget.message.sender == user!.email) {
                          showAlert(assignee.status, index);
                        }
                      },
                      icon: const Icon(Icons.done),
                    )
                  : MaterialButton(
                      onPressed: () {
                        if(widget.message.sender == user!.email) {
                          showAlert(assignee.status, index);
                        }
                      },
                      child: Text(assignee.getPrice()),
                    ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Payment Summary'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: Text(
                  widget.message.getPrice(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.message.description ?? ' ',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.message.assignees.length,
              itemBuilder: (context, index) {
                var assignee = widget.message.assignees[index];
                return assigneeCard(assignee, index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
