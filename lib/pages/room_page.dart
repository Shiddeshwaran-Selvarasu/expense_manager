import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/room.dart';
import '../tabs/chat_tab.dart';
import '../tabs/feed_tab.dart';
import '../tabs/people_tab.dart';

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
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withAlpha(50),
              foregroundImage: const NetworkImage(
                "https://img.freepik.com/free-icon/user_318-159711.jpg",
              ),
            ),
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
          const ChatView(),
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
