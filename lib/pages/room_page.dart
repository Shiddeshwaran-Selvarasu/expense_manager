import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/pages/request_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/constants.dart';
import '../models/room.dart';
import '../tabs/chat_tab.dart';
import '../tabs/feed_tab.dart';
import '../tabs/people_tab.dart';
import '../widgets/account_popup.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room});

  final Room room;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final user = FirebaseAuth.instance.currentUser;
  var index = 0;
  final snackBarred = const SnackBar(
    content: Text('No Internet! Check your connection'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  late PageController pageController = PageController(
    initialPage: index,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.room.name),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!.data();
                var photo = data!['profileImageUrl'] ?? defaultProfileImage;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AccountPopUp(
                          action: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 15),
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RequestPage(),
                                    ),
                                  );
                                },
                                leading: const Icon(
                                  Icons.notifications,
                                  color: Colors.orangeAccent,
                                ),
                                title: const Text("Requests"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withAlpha(50),
                      foregroundImage: NetworkImage(photo),
                    ),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: CircleAvatar(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (newPage) {
          setState(() {
            index = newPage;
          });
        },
        children: [
          ChatView(
            room: widget.room,
          ),
          Feeds(
            room: widget.room,
          ),
          People(
            room: widget.room,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (pos) {
          setState(() {
            index = pos;
            pageController.jumpToPage(pos);
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 75,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed_outlined),
            selectedIcon: Icon(Icons.feed_rounded),
            label: 'Feeds',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Peoples',
          ),
        ],
      ),
    );
  }
}
