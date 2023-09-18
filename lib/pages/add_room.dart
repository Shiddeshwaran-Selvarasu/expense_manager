import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/room.dart';

class AddRoom extends StatefulWidget {
  const AddRoom({Key? key}) : super(key: key);

  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameCon = TextEditingController();
  String? nameErrText = null;

  void _showToast(String text, Color color) {
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: color,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 250,
    );
  }

  int getRandomImage() {
    Random ram = Random();
    return ram.nextInt(9);
  }

  createClassRoom() {
    var room = Room.createRoom(
      name: _nameCon.value.text,
      admin: user!.email!,
    );
    if (_nameCon.value.text != '') {
      var snapshot =
          FirebaseFirestore.instance.collection('/rooms').doc(room.code);
      snapshot.get().then((value) {
        if (value.exists) {
          _showToast("something Went Wrong Try Again!", Colors.redAccent);
        } else {
          snapshot.set(room.toJson());
          _showToast("Room Created", Colors.greenAccent);
        }
      });
      FirebaseFirestore.instance.collection('/users').doc(user!.email).update({
        'rooms': FieldValue.arrayUnion([snapshot]),
      });
      Navigator.pop(context);
    } else {
      setState(() {
        nameErrText = 'Name can\'t be Empty';
      });
      _showToast("Name Field Cannot be Empty", Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Room",
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: () {
              createClassRoom();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextField(
                controller: _nameCon,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  errorText: nameErrText,
                  hintText: 'Enter Room Name',
                  labelText: 'Room Name',
                ),
                onChanged: (text) {
                  if (text == '') {
                    setState(() {
                      nameErrText = 'Name can\'t be Empty';
                    });
                  } else {
                    setState(() {
                      nameErrText = null;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
