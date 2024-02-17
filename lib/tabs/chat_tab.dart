import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/pages/add_payment.dart';
import 'package:expense_manager/pages/income_view.dart';
import 'package:expense_manager/utils/time_handler.dart';
import 'package:expense_manager/widgets/message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat.dart';
import '../models/room.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  NumberFormat myFormat = NumberFormat.currency(
    locale: 'en_in',
    symbol: '\u{20B9}',
    decimalDigits: 2,
  );

  getIncome(List<Message> messages) {
    double value = 0.0;

    if (messages.isEmpty) return myFormat.format(value);

    for (var message in messages) {
      if (message.sender == user!.email) {
        for (var assignee in message.assignees) {
          if (assignee.email != user!.email && !assignee.status) {
            value += assignee.amount;
          }
        }
      }
    }
    return myFormat.format(value);
  }

  getExpense(List<Message> messages) {
    double value = 0.0;

    if (messages.isEmpty) return myFormat.format(value);

    for (var message in messages) {
      if (message.sender != user!.email) {
        for (var assignee in message.assignees) {
          if (assignee.email == user!.email && !assignee.status) {
            value += assignee.amount;
          }
        }
      }
    }
    return myFormat.format(value);
  }

  bool isNextDay(Message msg1, Message msg2) {
    var day1 = DateTime(
      msg1.createdDate.toDate().year,
      msg1.createdDate.toDate().month,
      msg1.createdDate.toDate().day,
    );
    var day2 = DateTime(
      msg2.createdDate.toDate().year,
      msg2.createdDate.toDate().month,
      msg2.createdDate.toDate().day,
    );
    return (day2.difference(day1).inDays >= 1);
  }

  sendMessage(String text) {
    Message message = Message.from(
      id: ' ',
      sender: user!.email!,
      createdDate: Timestamp.now(),
      description: text,
    );
    FirebaseFirestore.instance
        .collection('rooms/${widget.room.code}/chats')
        .add(message.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              // color: Theme.of(context).colorScheme.secondaryContainer,
              color: Colors.transparent,
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('/rooms/${widget.room.code}/chats')
                  .orderBy("createdDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                List<Message> messages = [];
                if (snapshot.hasData) {
                  for (var element in snapshot.data!.docs) {
                    messages.add(Message.fromJson(element.data(), element.id));
                  }
                }
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.greenAccent.withAlpha(150),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IncomeView(
                                    messages: messages,
                                    isIncome: true,
                                  ),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(getIncome(messages)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.redAccent.withAlpha(150),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IncomeView(
                                    messages: messages,
                                    isIncome: false,
                                  ),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(getExpense(messages)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
                  List<Message> messages = [];
                  for (var element in snapshot.data!.docs) {
                    messages.add(Message.fromJson(element.data(), element.id));
                  }
                  return messages.isNotEmpty
                      ? ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (index == messages.length - 1 ||
                                    isNextDay(
                                        messages[index + 1], messages[index]))
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.withAlpha(50),
                                        ),
                                        child: Text(
                                          DateTimeHandler.getDateDiff(
                                            messages[index]
                                                .createdDate
                                                .toDate(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                MessageTile(
                                  message: messages[index],
                                  room: widget.room,
                                ),
                              ],
                            );
                          },
                        )
                      : const Center(
                          child: Text("No Chats to show..."),
                        );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 5),
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Send a message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.10,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withAlpha(200),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (controller.text.trim() != '') {
                          sendMessage(controller.value.text);
                        }
                        controller.clear();
                      },
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.10,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withAlpha(200),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddSplit(
                              room: widget.room,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payments_sharp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
