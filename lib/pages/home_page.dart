import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/utils/login_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        centerTitle: true,
        title: const Text('Expense Manager'),
        leading: IconButton(
          onPressed: () {
            final provider = Provider.of<LoginProvider>(context, listen: false);
            provider.logout();
          },
          icon: const Icon(Icons.logout_rounded),
        ),
        actions: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!.data();
                  var photo = data!['photo'] ??
                      "https://img.freepik.com/free-icon/user_318-159711.jpg";
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withAlpha(50),
                      foregroundImage: NetworkImage(photo),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    child: CircularProgressIndicator(),
                  ),
                );
              }),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!.data() ?? {};
              List groups = data!['groups'] ?? [];
              if (groups.isEmpty) {
                return const Center(
                  child: Text('Not in any group!!!'),
                );
              }
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(data['name']),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
