import 'package:flutter/cupertino.dart';

const String defaultProfileImage =
    "https://img.freepik.com/free-icon/user_318-159711.jpg";

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
    return double.parse(
        controller.value.text.isEmpty ? '0.0' : controller.value.text);
  }
}
