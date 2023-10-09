import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/room.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            color: Colors.blueAccent,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                    child: Container(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                    child: Container(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('/rooms/${widget.room.code}/chats')
                  .orderBy("createdDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var messages = [];
                  for (var element in snapshot.data!.docs) {
                    messages.add(element.id);
                  }
                  return messages.isNotEmpty
                      ? ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(messages[index].toString()),
                          ),
                        )
                      : const Center(
                          child: Text("No Feeds to show..."),
                        );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Container(
            height: 50,
            color: Colors.greenAccent,
          )
        ],
      ),
    );
  }
}
