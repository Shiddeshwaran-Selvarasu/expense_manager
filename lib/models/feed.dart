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

  Map<String, dynamic> toMap(){
    return {
      'title' : title,
      'imageURL': imageURL,
      'description': description,
      'createdAt': createdAt,
      'author' : author,
      'authorProfile': authorProfile,
    };
  }

  static Feed fromJson(var data) {
    print(data['title']);
    return Feed.from(
      title: data['title'] ?? '',
      imageURL: data['imageURL'],
      description: data['description'],
      createdAt: data['createdAt'],
      author: data['author'],
      authorProfile: data['authorProfile'] ?? '',
    );
  }
}
