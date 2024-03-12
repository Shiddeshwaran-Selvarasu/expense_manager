import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/chat.dart';
import 'package:expense_manager/pages/transction_report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../models/constants.dart';

class IncomeView extends StatefulWidget {
  const IncomeView({required this.messages, required this.isIncome, super.key});

  final List<Message> messages;
  final bool isIncome;

  @override
  State<IncomeView> createState() => _IncomeViewState();
}

class _IncomeViewState extends State<IncomeView> {
  final user = FirebaseAuth.instance.currentUser;
  NumberFormat myFormat = NumberFormat.currency(
    locale: 'en_in',
    symbol: '\u{20B9}',
    decimalDigits: 2,
  );

  void _showToast(String text,bool isError) {
    String color = isError ? "#ff3333":"#4caf50";
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: isError ? Colors.red : Colors.green,
      webBgColor: color,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
    );
  }

  getTotal(isIncome) {
    double value = 0.0;
    if (widget.messages.isEmpty) return value;

    if (isIncome) {
      for (var message in widget.messages) {
        if (message.sender == user!.email) {
          for (var assignee in message.assignees) {
            if (assignee.email != user!.email && !assignee.status) {
              value += assignee.amount;
            }
          }
        }
      }
    } else {
      for (var message in widget.messages) {
        if (message.sender != user!.email) {
          for (var assignee in message.assignees) {
            if (assignee.email == user!.email && !assignee.status) {
              value += assignee.amount;
            }
          }
        }
      }
    }

    return value;
  }

  Widget assigneeCard(Assignee assignee, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(email)
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
              trailing: Text(assignee.getPrice()),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget transactionList() {
    List<Widget> transactions = [];

    if (widget.isIncome) {
      for (var message in widget.messages) {
        if (message.sender == user!.email) {
          for (var assignee in message.assignees) {
            if (assignee.email != user!.email && !assignee.status) {
              transactions.add(assigneeCard(assignee, assignee.email));
            }
          }
        }
      }
    } else {
      for (var message in widget.messages) {
        if (message.sender != user!.email) {
          for (var assignee in message.assignees) {
            if (assignee.email == user!.email && !assignee.status) {
              transactions.add(assigneeCard(assignee, message.sender));
            }
          }
        }
      }
    }

    List<Widget> transactionCards = [];

    setState(() {
      transactionCards.clear();
      transactionCards.addAll(transactions);
      transactions.clear();
    });

    return transactionCards.isNotEmpty
        ? ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactionCards.length,
            itemBuilder: (context, index) {
              return transactionCards[index];
            },
          )
        : const Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text('No Transactions pending....'),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.isIncome ? 'Income' : 'Expanse'} Summary'),
        actions: [
          IconButton(
            onPressed: () {
              print(getTotal(true));
              print(getTotal(false));
              if (!(getTotal(true) == 0) || !(getTotal(false) == 0)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionReport(
                      isIncome: widget.isIncome,
                      messages: widget.messages,
                    ),
                  ),
                );
              } else {
                _showToast('Zero income and Expense', true);
              }
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
        ],
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
                  myFormat.format(getTotal(widget.isIncome)),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Divider(),
            transactionList(),
          ],
        ),
      ),
    );
  }
}
