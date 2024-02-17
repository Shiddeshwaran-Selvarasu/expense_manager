import 'package:flutter/cupertino.dart';

const String defaultProfileImage =
    "https://img.freepik.com/free-icon/user_318-159711.jpg";
const String feedBackEmail = 'pcdev.tech@gmail.com';
const String sendGridToken =
    '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';

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
