import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/chat.dart';
import 'package:expense_manager/models/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';

class AddPayment extends StatefulWidget {
  const AddPayment({required this.room, super.key});

  final Room room;

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  final user = FirebaseAuth.instance.currentUser;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? amountError;
  final List<AssigneeTextField> _assigneeControllers = [];
  double defaultVal = 0.0;
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
                    if (txt.isEmpty) {
                      _assigneeControllers[index].controller.text = '0.0';
                    }
                    setState(() {
                      defaultVal = double.parse('0.0');
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
      if(assTxt.getVal() == 0.0){
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
      totalAmount: double.parse(_amountController.value.text),
    );

    FirebaseFirestore.instance.collection('rooms/${widget.room.code}/chats').add(message.toMap());
  }

  getDiff() {
    double total = defaultVal;
    try {
      total = double.parse(_amountController.value.text);
    } catch (e) {
      print(e);
    }
    double sum = 0.0;

    for (AssigneeTextField assTxt in _assigneeControllers) {
      sum += assTxt.getVal();
    }

    return total - sum;
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
              if (_amountController.value.text.isNotEmpty &&
                  _assigneeControllers.isNotEmpty) {
                Navigator.pop(context);
                sendMessage();
              } else if (_amountController.value.text.isEmpty) {
                setState(() {
                  amountError = 'Amount can\'t be empty';
                });
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 10),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      errorText: amountError,
                      hintText: 'Enter Total Amount',
                      labelText: 'Total Amount',
                    ),
                    onChanged: (text) {
                      setState(() {
                        if (text.isNotEmpty) {
                          amountError = null;
                        }
                        defaultVal = 0.0;
                      });
                      double val = 0.0;
                      if (text.isNotEmpty) {
                        val = double.parse(text) / widget.room.members.length;
                      }
                      for (AssigneeTextField assTxt in _assigneeControllers) {
                        assTxt.changeVal(val);
                      }
                    },
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
                    if (snapshot.hasData) {
                      UserData userDate =
                          UserData.fromMap(snapshot.data!.data()!);
                      return assigneeCard(userDate, index);
                    }
                    return const SizedBox();
                  },
                );
              },
            ),
            if (getDiff() != 0.0)
              Text(
                'Difference Amount: ${myFormat.format(getDiff().abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getDiff() < 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
