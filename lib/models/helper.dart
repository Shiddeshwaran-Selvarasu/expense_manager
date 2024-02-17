import 'package:flutter/material.dart';

import 'constants.dart';

class AddPeopleList {
  AddPeopleList({
    required this.controller,
    required this.key,
    this.errorText = null,
    this.isOptional = false,
  });

  final TextEditingController controller;
  final String key;
  String? errorText;
  bool isOptional;
}

class UserList {
  UserList({
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  final String name;
  final String email;
  final String imageUrl;

  factory UserList.unknownUser({String? email}){
    return UserList(
      name: 'Unknown User',
      email: email ?? 'nil',
      imageUrl: defaultProfileImage,
    );
  }
}