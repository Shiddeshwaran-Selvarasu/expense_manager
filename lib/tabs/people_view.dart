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
  List<UserList> peopleList = [];
  final user = FirebaseAuth.instance.currentUser;

  final snackBar = const SnackBar(
    content: Text('Access Denied! you are not a Teacher'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  getPeopleList() async {
    peopleList.clear();
    await FirebaseFirestore.instance
        .doc('/rooms/${widget.room.code}')
        .get()
        .then((value) {
      var list = value.data()?['people'];
      for (String s in list) {
        FirebaseFirestore.instance.doc('/users/$s').get().then((value) {
          if (value.data() != null) {
            Map<String, dynamic> data = value.data()!;
            setState(() {
              peopleList.add(UserList(
                  name: data['name'],
                  email: data['email'],
                  imageUrl: data['profileImageUrl']));
            });
          }
        });
      }
    });
  }

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
                    Navigator.pop(context);
                    deleteMember(userList);
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
    if (user!.email == widget.room.admin) {
    } else {
      setState(() {
        peopleList.remove(userList);
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            peopleList.clear();
          });
          getPeopleList();
        },
        child: ListView.builder(
          itemCount: peopleList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ListTile(
              leading: CircleAvatar(
                foregroundImage: NetworkImage(peopleList[index].imageUrl),
              ),
              title: Text(
                peopleList[index].name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: peopleList[index].email == widget.room.admin
                  ? const Text('admin')
                  : const Text('member'),
              trailing: deleteMemberButton(peopleList[index]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addMember,
        child: const Icon(Icons.add),
      ),
    );
  }
}
