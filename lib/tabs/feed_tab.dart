import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/feed.dart';
import '../models/room.dart';
import '../pages/add_feeds.dart';
import '../pages/feed_view.dart';
import '../utils/time_handler.dart';

class Feeds extends StatefulWidget {
  const Feeds({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  final user = FirebaseAuth.instance.currentUser;
  final snackBar = const SnackBar(
    content: Text('Access Denied! you are not a Teacher'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  final feedDeleteError = const SnackBar(
    content: Text('Something went wrong! please restart and try again.'),
    backgroundColor: Colors.yellowAccent,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
  );

  addFeeds() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFeeds(
          code: widget.room.code,
        ),
      ),
    );
  }

  deleteFeed(Feed feed) {
    if (feed.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(feedDeleteError);
    } else {
      FirebaseFirestore.instance
          .collection('rooms/${widget.room.code}/Feeds')
          .doc(feed.id!)
          .delete()
          .onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(feedDeleteError);
      });
    }
  }

  showAlert(value) {
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
          content: const Text("Are sure you want to delete The Post?"),
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
                  deleteFeed(value);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('/rooms/${widget.room.code}/Feeds')
            .snapshots(),
        builder: (context, snapshot) {
          var feedsList = [];

          if (snapshot.hasData) {
            for (var element in snapshot.data!.docs) {
              var feedItem = Feed.fromJson(element.data());
              feedItem.id = element.id;
              feedsList.add(feedItem);
            }
            return feedsList.isNotEmpty
                ? ListView.builder(
                    itemCount: feedsList.length,
                    itemBuilder: (context, index) =>
                        feedsCard(feedsList[index]),
                  )
                : const Center(
                    child: Text("No Feeds to show..."),
                  );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFeeds,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget feedsCard(Feed value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        color: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedView(feed: value),
              ),
            );
          },
          child: Wrap(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 23,
                  foregroundImage: NetworkImage(value.authorProfile),
                ),
                title: Text(
                  value.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                    DateTimeHandler.getDateTimeDiff(value.createdAt.toDate())),
                trailing: user!.email == widget.room.admin
                    ? IconButton(
                        onPressed: () {
                          showAlert(value);
                        },
                        icon: const Icon(Icons.delete),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                  right: 15,
                  left: 15,
                ),
                child: Text(
                  value.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  softWrap: true,
                ),
              ),
              value.imageURL != ''
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          value.imageURL,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
