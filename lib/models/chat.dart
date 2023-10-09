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
      'amount': amount,
      'status': status,
    };
  }

  static Assignee fromJson(var data) {
    return Assignee.from(
      assignee: data['assignee'],
      amount: data['amount'],
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
    required this.totalAmount,
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
      'totalAmount': totalAmount,
      'description': description,
      'createdDate': createdDate,
      'assignees': assignees,
    };
  }

  static Message fromJson(var data) {
    List<Assignee> assigneesList = [];
    data['assignees'].forEach((e) => assigneesList.add(Assignee.fromJson(e)));
    return Message.from(
      sender: data['sender'],
      totalAmount: data['totalAmount'],
      description: data['description'],
      createdDate: data['createdDate'],
      assignees: assigneesList,
    );
  }
}
