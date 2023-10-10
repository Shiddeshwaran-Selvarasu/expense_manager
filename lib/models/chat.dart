import 'package:cloud_firestore/cloud_firestore.dart';

class Assignee {
  final String assignee;
  final Timestamp? doneAt;
  final double amount;
  final bool status;

  Assignee.from({
    required this.assignee,
    required this.amount,
    required this.status,
    this.doneAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'assignee': assignee,
      'doneAt': doneAt,
      'amount': amount.toString(),
      'status': status,
    };
  }

  static Assignee fromJson(var data) {
    return Assignee.from(
      assignee: data['assignee'],
      amount: double.parse(data['amount']),
      doneAt: data['doneAt'],
      status: data['status'],
    );
  }
}

class Message {
  final String sender;
  final String? description;
  final double totalAmount;
  final List<Assignee> assignees;
  final Timestamp createdDate;

  Message.from({
    required this.sender,
    this.totalAmount = 0,
    required this.createdDate,
    this.assignees = const [],
    this.description,
  });

  addAssignees(Assignee assignee) {
    assignees.add(assignee);
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'totalAmount': totalAmount.toString(),
      'description': description,
      'createdDate': createdDate,
      'assignees': assignees,
    };
  }

  static Message fromJson(var data) {
    List<Assignee> assigneesList = [];
    if (data['assignees'] != null) {
      data['assignees'].forEach(
        (e) => assigneesList.add(Assignee.fromJson(e)),
      );
    }
    return Message.from(
      sender: data['sender'],
      totalAmount: double.parse(data['totalAmount'] ?? "0"),
      description: data['description'],
      createdDate: data['createdDate'],
      assignees: assigneesList,
    );
  }
}
