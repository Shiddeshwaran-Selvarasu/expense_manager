import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  var classNames = [];
  final user = FirebaseAuth.instance.currentUser;

  final snackBarred = const SnackBar(
    content: Text('Accpeted The Request!'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  final snackBarredred = const SnackBar(
    content: Text('Rejected The Request!'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  @override
  void initState() {
    getclassName();
    super.initState();
  }

  removeRequest(int index) {
    setState(() {
      classNames.removeAt(index);
    });
    widget.requestList[index].update({
      'people' : FieldValue.arrayRemove([
        user!.email,
      ]),
      'teachers' : FieldValue.arrayRemove([
        user!.email,
      ]),
    });
    FirebaseFirestore.instance.doc('/users/${user!.email}').update({
      'requests': FieldValue.arrayRemove([
        widget.requestList[index],
      ]),
    });
    ScaffoldMessenger.of(context).showSnackBar(snackBarredred);
  }

  acceptRequest(int index) {
    setState(() {
      classNames.removeAt(index);
    });
    FirebaseFirestore.instance.doc('/users/${user!.email}').update({
      'classrooms': FieldValue.arrayUnion([
        widget.requestList[index],
      ]),
      'requests': FieldValue.arrayRemove([
        widget.requestList[index],
      ]),
    });
    ScaffoldMessenger.of(context).showSnackBar(snackBarred);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          title: Text(
            "Zorion ClassRoom",
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
        ),
        body: classNames.isNotEmpty ? ListView.builder(
          itemCount: classNames.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(widget.requestList[index].toString()),
              onDismissed: (direction) {
                removeRequest(index);
              },
              background: Container(
                color: Colors.red,
              ),
              child: ListTile(
                title: Text(classNames[index],style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                trailing: IconButton(
                  onPressed: (){
                    acceptRequest(index);
                  },
                  icon: const Icon(Icons.check),
                ),
              ),
            );
          },
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 40,),
            Image.asset('assets/dash.png'),
            const Text('All Clear!, There is no Requests Right Now.',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
          ],
        )
    );
  }
}
