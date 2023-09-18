import 'package:flutter/material.dart';

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
}