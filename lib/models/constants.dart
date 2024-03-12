import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'chat.dart';

const String defaultProfileImage =
    "https://img.freepik.com/free-icon/user_318-159711.jpg";
const String feedBackEmail = 'feedback.pcdev@gmail.com';

const double point = 1.0;
const double inch = 72.0;
const double cm = inch / 2.54;
const double mm = inch / 25.4;

const PdfPageFormat customPageFormat = PdfPageFormat(
  21.0 * cm,
  29.7 * cm,
  marginAll: 30,
);

class UserData {
  final String name;
  final String email;
  final String profileImageUrl;
  final List rooms;

  const UserData({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.rooms,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'rooms': rooms,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    List rooms = [];

    if (map['rooms'] != null) {
      map['rooms'].forEach((e) => rooms.add(e));
    }

    return UserData(
      name: map['name'] as String,
      email: map['email'] as String,
      profileImageUrl: map['profileImageUrl'] as String,
      rooms: rooms,
    );
  }
}

// class GraphData {
//   final String sender;
//   final String receiver;
//   final DateTime createdTime;
//   final double amount;
//
//   GraphData({
//     required this.sender,
//     required this.receiver,
//     required this.createdTime,
//     required this.amount,
//   });
//
//   static GraphData fromMessageList(Message message) {
//
//     return GraphData(
//       sender: message.sender,
//       receiver: email,
//       createdTime: message.createdDate.toDate(),
//       amount: message.getSharePrice(email),
//     );
//   }
// }

class AssigneeTextField {
  final String email;
  final TextEditingController controller;
  String? error;

  AssigneeTextField({
    required this.email,
    required this.controller,
  });

  changeVal(double val) {
    controller.text = val.toString();
  }

  double getVal() {
    if (controller.value.text.isEmpty) {
      return 0;
    }
    return double.parse(controller.value.text);
  }
}
