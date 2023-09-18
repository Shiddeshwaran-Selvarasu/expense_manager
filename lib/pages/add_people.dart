import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/helper.dart';

class AddPeople extends StatefulWidget {
  const AddPeople({Key? key, required this.code})
      : super(key: key);

  final String code;

  @override
  State<AddPeople> createState() => _AddPeopleState();
}

class _AddPeopleState extends State<AddPeople> {
  List<AddPeopleList> conList = [
    AddPeopleList(controller: TextEditingController(), key: "getUniqueKey()")
  ];

  void _showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 250,
    );
  }

  getUniqueKey() {
    String charSet = '${DateTime.now()}AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    charSet = charSet.replaceAll(RegExp(r'[^\w]+'), '');
    Random ram = Random();
    return String.fromCharCodes(Iterable.generate(
        25, (_) => charSet.codeUnitAt(ram.nextInt(charSet.length))));
  }

  addEmail() {
    setState(() {
      conList.add(AddPeopleList(
          controller: TextEditingController(), key: getUniqueKey()));
    });
  }

  checkFields() {
    var count = 0;
    for (var element in conList) {
      var text = element.controller.value.text;
      if (EmailValidator.validate(text)) {
        setState(() {
          element.errorText = 'Enter a Valid Email!';
        });
      } else {
        count++;
      }
    }
    if (count == 0) {
      return true;
    } else {
      return false;
    }
  }

  sendRequest(addlist) {
    for (String e in addlist) {
      var snapshot = FirebaseFirestore.instance.doc('/users/$e');
      snapshot.get().then((value) {
        if (value.exists) {
          snapshot.update({
            'requests': FieldValue.arrayUnion(
              [FirebaseFirestore.instance.doc('/classrooms/${widget.code}')],
            ),
          });
        }
      });
    }
  }

  addPeople() {
    if (checkFields()) {
      List<dynamic> addslist = [];
      List<dynamic> addtlist = [];
      for (var element in conList) {
        if (EmailValidator.validate(element.controller.value.text)) {
          if (element.isTeacher) {
            addtlist.add(element.controller.value.text);
          }
          addslist.add(element.controller.value.text);
        }
      }
      FirebaseFirestore.instance.doc('/classrooms/${widget.code}').update({
        'people': FieldValue.arrayUnion(addslist),
        'teachers': FieldValue.arrayUnion(addtlist),
      }).then((value) {
        sendRequest(addslist);
        _showToast("Members Added! Refresh the page to See the changes.");
      }).onError((error, stackTrace) {
        _showToast(error.toString());
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add People",
          style: TextStyle(
            color: brightness == Brightness.light ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor:
        brightness == Brightness.dark ? Colors.black26 : Colors.white,
        leading: IconButton(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            color: brightness == Brightness.light ? Colors.black : Colors.white,
            onPressed: () {
              if (addPeople()) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: conList.isEmpty
          ? const Center(
        child: Text("Click the Add button to start Adding people."),
      )
          : ListView.builder(
          itemCount: conList.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(conList[index].key),
              onDismissed: (_) {
                setState(() {
                  conList.remove(conList[index]);
                });
              },
              background: Container(color: Colors.red),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      setState(() {
                        if (conList[index].isTeacher) {
                          conList[index].isTeacher = false;
                        } else {
                          conList[index].isTeacher = true;
                        }
                      });
                    },
                    icon: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: conList[index].isTeacher
                          ? Colors.blue
                          : Colors.blueGrey,
                      size: 30,
                    ),
                  ),
                  title: TextField(
                    controller: conList[index].controller,
                    decoration: InputDecoration(
                      hintText: conList[index].isTeacher
                          ? 'Enter Teacher Email'
                          : 'Enter Student Email',
                      labelText: conList[index].isTeacher
                          ? 'Teacher Email'
                          : 'Student Email',
                      errorText: conList[index].errorText,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (text) {
                      if (EmailValidator.validate(text)) {
                        setState(() {
                          conList[index].errorText = null;
                        });
                      } else {
                        setState(() {
                          conList[index].errorText = 'Enter a Valid Email!';
                        });
                      }
                    },
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: addEmail,
        child: const Icon(Icons.add),
      ),
    );
  }
}
