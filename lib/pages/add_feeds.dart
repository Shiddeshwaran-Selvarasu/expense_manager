import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddFeeds extends StatefulWidget {
  const AddFeeds({Key? key, required this.refreshFeeds, required this.code})
      : super(key: key);

  final String code;
  final Function refreshFeeds;

  @override
  _AddFeedsState createState() => _AddFeedsState();
}

class _AddFeedsState extends State<AddFeeds> {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController tileController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  String? titleError = null;
  String? contentError = null;

  void _showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 250,
    );
  }

  checkFields() {
    int count = 0;
    var text1 = tileController.value.text;
    var text2 = contentController.value.text;
    if (text1 == '') {
      setState(() {
        titleError = 'Title Can\'t be Empty';
      });
      count++;
    }
    if (text2 == '') {
      setState(() {
        contentError = 'Content Can\'t be Empty';
      });
      count++;
    }
    if (count == 0) {
      return true;
    } else {
      return false;
    }
  }

  addFeeds(){
    if(checkFields()){
      var snapshot = FirebaseFirestore.instance.collection('/rooms/${widget.code}/Feeds').add({
        'author' : user!.displayName,
        'authorImage' : user!.photoURL,
        'time' : Timestamp.fromDate(DateTime.now()),
        'title' : tileController.value.text,
        'image' : imageController.value.text,
        'link' : linkController.value.text,
        'content' : contentController.value.text,
      });
      snapshot.then((value) {
        print(value.id);
        _showToast("Feeds Updated!");
      });
      snapshot.catchError((e){
        _showToast(e);
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
          "Add Feeds",
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
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              color: brightness == Brightness.light ? Colors.black : Colors.white,
              onPressed: () {
                if (addFeeds()) {
                  widget.refreshFeeds();
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.check),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: TextField(
                controller: tileController,
                decoration: InputDecoration(
                  hintText: 'Enter Title',
                  labelText: 'Title',
                  errorText: titleError,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                onChanged: (text){
                  if (text == '') {
                    setState(() {
                      titleError = 'Title Can\'t be Empty';
                    });
                  } else {
                    setState(() {
                      titleError = null;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  hintText: 'Enter Image Url',
                  labelText: 'Image Url',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: 'Enter Content',
                  labelText: 'Content',
                  errorText: contentError,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                onChanged: (text){
                  if (text == '') {
                    setState(() {
                      contentError = 'Content Can\'t be Empty';
                    });
                  } else {
                    setState(() {
                      contentError = null;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  hintText: 'Enter Link',
                  labelText: 'Link',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
