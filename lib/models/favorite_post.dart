import 'package:flutter/foundation.dart';

class Favorite {
  String type;
  String postId;

  Favorite({
    @required this.type,
    @required this.postId,
  });

  static Map<String, String> toMap(Favorite favorite) {
    return {
      'type': favorite.type,
      'postId': favorite.postId,
    };
  }

  factory Favorite.fromMap(Map<String, String> map) {
    return Favorite(postId: map['postId'], type: map['type']);
  }
}
