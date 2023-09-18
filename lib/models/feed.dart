import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  String title;
  String imageURL;
  String description;
  Timestamp createdAt;
  String author;
  String link;
  String authorProfile;

  Feed.from({
    required this.title,
    required this.imageURL,
    required this.description,
    this.link = "",
    required this.createdAt,
    required this.author,
    required this.authorProfile,
  });
}
