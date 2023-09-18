import 'package:flutter/material.dart';

import '../models/feed.dart';
import '../utils/time_handler.dart';

class FeedView extends StatelessWidget {
  const FeedView({Key? key, required this.feed}) : super(key: key);

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Feed"),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      foregroundImage: NetworkImage(feed.authorProfile),
                    ),
                    title: Text(
                      feed.author,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                        TimeHandler().getTimeDiff(feed.createdAt.toDate())),
                  ),
                  const Divider(
                    thickness: 1.2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      feed.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              feed.imageURL != ''
                  ? Image.network(feed.imageURL)
                  : const SizedBox(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(feed.description, textAlign: TextAlign.justify),
              ),
              feed.link != ''
                  ? TextButton(
                      onPressed: () {},
                      child: Text(
                        feed.link,
                        style: const TextStyle(color: Colors.blue),
                      ))
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
