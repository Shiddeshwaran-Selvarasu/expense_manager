import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final user = FirebaseAuth.instance.currentUser;

  final snackBarGreen = const SnackBar(
    content: Text('Accepted The Request!'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  final snackBarRed = const SnackBar(
    content: Text('Rejected The Request!'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  removeRequest(requestReference) {
    FirebaseFirestore.instance.doc('/users/${user!.email}').update({
      'requests': FieldValue.arrayRemove([requestReference]),
    });
    ScaffoldMessenger.of(context).showSnackBar(snackBarRed);
  }

  acceptRequest(requestReference) {
    FirebaseFirestore.instance.doc('/users/${user!.email}').update({
      'rooms': FieldValue.arrayUnion([requestReference]),
      'requests': FieldValue.arrayRemove([requestReference]),
    });
    ScaffoldMessenger.of(context).showSnackBar(snackBarGreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: const Text("Expanse Manager"),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('/users')
            .doc(user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          var requestList = [];

          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!.data() ?? {};
            requestList = data['requests'] ?? [];
            return requestList.isNotEmpty
                ? ListView.builder(
                    itemCount: requestList.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: requestList[index].snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Map<String, dynamic> roomData =
                                snapshot.data!.data() ?? {};
                            return Dismissible(
                              key: Key(requestList[index].toString()),
                              onDismissed: (direction) {
                                removeRequest(index);
                              },
                              background: Container(
                                color: Colors.red,
                              ),
                              child: ListTile(
                                title: Text(
                                  roomData['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    acceptRequest(requestList[index]);
                                  },
                                  icon: const Icon(Icons.check),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Image.asset('assets/dash.png'),
                        const Text(
                          'All Clear!, There is no Requests Right Now.',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
