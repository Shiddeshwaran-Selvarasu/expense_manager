import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/helper.dart';
import '../models/room.dart';
import '../pages/add_people.dart';

class People extends StatefulWidget {
  const People({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  final user = FirebaseAuth.instance.currentUser;

  final snackBar = const SnackBar(
    content: Text('Access Denied! you are not The Admin'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  addMember() {
    if (user!.email == widget.room.admin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPeople(code: widget.room.code),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  showAlert(UserList userList) {
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
            content: Text(
                "Are sure you want to delete ${userList.email} (${userList.name})?"),
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
                    deleteMember(userList);
                    Navigator.pop(context);
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
        });
  }

  deleteMember(UserList userList) {
    print(user!.email);
    print(widget.room.admin);
    if (user!.email == widget.room.admin) {
      setState(() {
        print(userList.email);
        FirebaseFirestore.instance.doc('/rooms/${widget.room.code}').update({
          'people': FieldValue.arrayRemove([userList.email]),
        });
      });
    }
  }

  Widget? deleteMemberButton(UserList userList) {
    if (widget.room.admin == user!.email!) {
      if (userList.email != widget.room.admin) {
        return IconButton(
          onPressed: () => showAlert(userList),
          icon: const Icon(Icons.delete),
        );
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('/rooms')
            .doc(widget.room.code)
            .snapshots(),
        builder: (context, snapshot) {
          List<dynamic> peopleList = [];

          if (snapshot.hasData) {
            var data = snapshot.data!.data() ?? {};
            peopleList = data['people'];
            return ListView.builder(
              itemCount: peopleList.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('/users')
                      .doc(peopleList[index])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var userData;
                      if (snapshot.data!.exists) {
                        var snapData = snapshot.data!.data() ?? {};
                        userData = UserList(
                            name: snapData['name'],
                            email: snapData['email'],
                            imageUrl: snapData['profileImageUrl']);
                      } else {
                        userData = UserList.unknownUser(
                          email: snapshot.data!.id,
                        );
                      }
                      return ListTile(
                        leading: CircleAvatar(
                          foregroundImage: NetworkImage(userData.imageUrl),
                        ),
                        title: Text(
                          userData.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          userData.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        trailing: deleteMemberButton(userData),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addMember,
        child: const Icon(Icons.add),
      ),
    );
  }
}
