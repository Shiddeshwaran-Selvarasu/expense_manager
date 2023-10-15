import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Assignee {
  final String email;
  final double amount;
  bool status;

  Assignee.from({
    required this.email,
    required this.amount,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'assignee': email,
      'amount': amount.toString(),
      'status': status,
    };
  }

  static Assignee fromJson(var data) {
    return Assignee.from(
      email: data['assignee'],
      amount: double.parse(data['amount']),
      status: data['status'],
    );
  }

  @override
  String toString(){
    return toMap().toString();
  }

  String getPrice() {
    NumberFormat myFormat = NumberFormat.currency(
        locale: 'en_in', symbol: '\u{20B9}', decimalDigits: 2);
    // myFormat.minimumFractionDigits = 2;
    // myFormat.maximumSignificantDigits = 2;
    return myFormat.format(amount);
  }
}

class Message {
  final String id;
  final String sender;
  final String? description;
  final double totalAmount;
  final List<Assignee> assignees;
  final Timestamp createdDate;

  Message.from({
    required this.id,
    required this.sender,
    this.totalAmount = 0,
    required this.createdDate,
    this.assignees = const [],
    this.description,
  });

  addAssignees(Assignee assignee) {
    assignees.add(assignee);
  }

  String getPrice() {
    NumberFormat myFormat = NumberFormat.currency(
      locale: 'en_in',
      symbol: '\u{20B9}',
      decimalDigits: 2,
    );
    return myFormat.format(totalAmount);
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> list = [];
    for (var element in assignees) {
      list.add(element.toMap());
    }
    return {
      'sender': sender,
      'totalAmount': totalAmount.toString(),
      'description': description,
      'createdDate': createdDate,
      'assignees': list,
    };
  }

  static Message fromJson(var data,String id) {
    List<Assignee> assigneesList = [];
    if (data['assignees'] != null) {
      data['assignees'].forEach(
        (e) => assigneesList.add(Assignee.fromJson(e)),
      );
    }
    return Message.from(
      id: id,
      sender: data['sender'],
      totalAmount: double.parse(data['totalAmount'] ?? "0"),
      description: data['description'],
      createdDate: data['createdDate'],
      assignees: assigneesList,
    );
  }
}
