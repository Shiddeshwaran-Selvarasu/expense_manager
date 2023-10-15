import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/pages/room_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/room.dart';

class RoomTile extends StatefulWidget {
  const RoomTile({super.key, required this.room});

  final DocumentReference room;

  @override
  State<RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  final user = FirebaseAuth.instance.currentUser;

  showAlert(Room room) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 30,
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text("Delete?"),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Text("Are sure you want to delete ${room.name}?"),
          actionsAlignment: MainAxisAlignment.end,
          elevation: 5,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  removeRoom(room);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  removeRoom(Room room) {
    FirebaseFirestore.instance.doc("/users/${user!.email}").update({
      'rooms': FieldValue.arrayRemove(
          [FirebaseFirestore.instance.doc('/rooms/${room.code}')]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.room.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var room =
              Room.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          return Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomPage(room: room),
                  ),
                );
              },
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/8377/8377384.png",
                    ),
                  ),
                  title: Text(
                    room.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(room.admin),
                  trailing: IconButton(
                    onPressed: () {
                      showAlert(room);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
