import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/chat.dart';
import 'package:expense_manager/models/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';

class AddSplit extends StatefulWidget {
  const AddSplit({required this.room, super.key});

  final Room room;

  @override
  State<AddSplit> createState() => _AddSplitState();
}

class _AddSplitState extends State<AddSplit> {
  final user = FirebaseAuth.instance.currentUser;
  double totalAmount = 0.0;
  final _descriptionController = TextEditingController();
  String? amountError;
  final List<AssigneeTextField> _assigneeControllers = [];
  NumberFormat myFormat = NumberFormat.currency(
    locale: 'en_in',
    symbol: '\u{20B9}',
    decimalDigits: 2,
  );

  Widget assigneeCard(UserData userData, int index) {
    if (_assigneeControllers.length <= index) {
      _assigneeControllers.add(
        AssigneeTextField(
          email: userData.email,
          controller: TextEditingController(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userData.email)
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
              trailing: SizedBox(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.15,
                child: TextField(
                  controller: _assigneeControllers[index].controller,
                  decoration: InputDecoration(
                    errorText: _assigneeControllers[index].error,
                  ),
                  onChanged: (txt) {
                    setState(() {
                      totalAmount = getTotal();
                    });
                  },
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  sendMessage() {
    List<Assignee> assignees = [];

    for (AssigneeTextField assTxt in _assigneeControllers) {
      if(assTxt.getVal() == 0){
        continue;
      }
      assignees.add(
        Assignee.from(
          email: assTxt.email,
          amount: assTxt.getVal(),
          status: assTxt.email == user!.email!,
        ),
      );
    }

    Message message = Message.from(
      id: 'gfhfhg',
      sender: user!.email!,
      createdDate: Timestamp.now(),
      assignees: assignees,
      description: _descriptionController.value.text,
      totalAmount: totalAmount,
    );

    FirebaseFirestore.instance.collection('rooms/${widget.room.code}/chats').add(message.toMap());
  }

  getTotal() {
    double total = 0;

    for(var assTxt in _assigneeControllers){
      total += assTxt.getVal();
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        centerTitle: true,
        title: const Text('Add Payment'),
        actions: [
          IconButton(
            onPressed: () {
              if (totalAmount > 0 &&
                  _assigneeControllers.isNotEmpty) {
                Navigator.pop(context);
                sendMessage();
              }
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: Text(
                  myFormat.format(totalAmount),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      hintText: 'Enter description',
                      labelText: 'Description',
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.room.members.length,
              itemBuilder: (context, index) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.room.members[index])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      UserData userDate =
                          UserData.fromMap(snapshot.data!.data()!);
                      return assigneeCard(userDate, index);
                    }
                    return const SizedBox();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
