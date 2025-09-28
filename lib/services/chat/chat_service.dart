import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitdcodes007/models/message.dart';

class ChatService {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return FirebaseFirestore.instance.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Add the document ID (email) into the returned data map
        final userData = doc.data() as Map<String, dynamic>;
        userData['email'] = doc.id; // Firebase document ID is the email
        return userData;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String recieverEmail, message) async {
    final String? currentUserEmail = _auth.currentUser!.email;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderEmail: currentUserEmail,
        recieverEmail: recieverEmail,
        message: message,
        timestamp: timestamp);

    List<String?> emails = [currentUserEmail, recieverEmail];
    emails.sort();

    String chatRoomId = emails.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userEmail, otherUserEmail) {
    List<String> emails = [userEmail, otherUserEmail];
    emails.sort();

    String chatRoomID = emails.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
