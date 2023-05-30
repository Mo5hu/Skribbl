import 'package:skribbl/models/player.dart';

class Message {
  final String message;
  final String? displayName;
  final String? photoURL;
  final String uid;
  final String? email;
  final bool guessingState;

  const Message(
      {this.email,
      required this.message,
      this.displayName,
      this.photoURL,
      required this.uid,
      required this.guessingState});

  factory Message.fromMap(Map<String, dynamic> data) {
    Message msg;
    if (data['email'] != null) {
      msg = Message(
        message: data['message'],
        displayName: data['displayName'],
        photoURL: data['photoURL'],
        email: data['email'],
        uid: data['uid'],
        guessingState: data['guessingState'],
      );
    } else {
      msg = Message(
        message: data['message'],
        guessingState: data['guessingState'],
        uid: data['uid'],
        displayName: data['displayName'],
        photoURL: data['photoURL'],
      );
    }

    return msg;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'message': message,
      'displayName': displayName,
      'photoURL': photoURL,
      'uid': uid,
      'email': email,
    };
    return map;
  }

  List<Object?> get props => [uid, displayName, photoURL, email, message];
}
