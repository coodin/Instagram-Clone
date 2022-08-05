import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String profImage;
  final String userName;
  final String description;
  final String commentID;
  final likes;
  final uid;
  final DateTime datePublis;

  const Comment({
    required this.uid,
    required this.userName,
    required this.description,
    required this.commentID,
    required this.likes,
    required this.datePublis,
    required this.profImage,
  });

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Comment(
      uid: snapshot["uid"],
      userName: snapshot["userName"],
      description: snapshot["description"],
      commentID: snapshot["commentId"],
      likes: snapshot["likes"],
      datePublis: snapshot["datePublis"].toDate(),
      profImage: snapshot["profImage"],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "userName": userName,
        "description": description,
        "commentId": commentID,
        "likes": likes,
        "datePublis": datePublis,
        "profImage": profImage,
      };
}
