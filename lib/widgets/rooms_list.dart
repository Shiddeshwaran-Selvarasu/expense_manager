import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/widgets/room_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomsList extends StatefulWidget {
  const RoomsList({super.key});

  @override
  State<RoomsList> createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data!.data() ?? {};
          List groups = data['rooms'] ?? [];
          if (groups.isEmpty) {
            return const Center(
              child: Text('Not in any Rooms!!!'),
            );
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return RoomTile(room: groups[index]);
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
