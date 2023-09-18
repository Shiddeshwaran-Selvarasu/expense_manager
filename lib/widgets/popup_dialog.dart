import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PopUpDialog extends StatefulWidget {
  const PopUpDialog({Key? key}) : super(key: key);

  @override
  _PopUpDialogState createState() => _PopUpDialogState();
}

class _PopUpDialogState extends State<PopUpDialog> {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController controller = TextEditingController();
  String? errortext = null;

  void _showToast(String text,Color color) {
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: color,
      gravity: ToastGravity.BOTTOM_LEFT,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 5,
    );
  }

  checkRoomCode(var text) {
    FirebaseFirestore.instance.doc('/users/${user!.email}').get().then((value) {
      var list = value.data()!['rooms'];
      if (list.toString().contains(text)) {
        _showToast("Already Enrolled!",Colors.blueAccent);
      } else {
        var snapshot = FirebaseFirestore.instance.collection('/rooms').doc(text);
        snapshot.get().then((value) {
          if (value.exists) {
            var peopleList = value.data()!['people'];
            if (peopleList.toString().contains(user!.email!)) {
              FirebaseFirestore.instance.doc('/users/${user!.email}').update({
                'rooms': FieldValue.arrayUnion([snapshot]),
              });
            }
          } else {
            _showToast("ClassRoom Not Found",Colors.grey);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 230,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding:
          const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Room Code:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 5, right: 10, left: 10),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Room Code',
                    errorText: errortext,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                  onChanged: (text) {
                    if (text.length < 7) {
                      setState(() {
                        errortext = 'Too short!';
                      });
                    } else if (text.length > 8) {
                      setState(() {
                        errortext = 'Should be at least 8 characters';
                      });
                    } else {
                      setState(() {
                        errortext = null;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.value.text.length != 8) {
                          _showToast("ClassRoom Code Invalid!",Colors.redAccent);
                        } else {
                          checkRoomCode(controller.value.text);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Enter"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
