//import 'package:chat/providers/chat_appwrite.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:provider/provider.dart';

class AppwriteNewMessage extends StatefulWidget {
  @override
  _AppwriteNewMessageState createState() => _AppwriteNewMessageState();
}

class _AppwriteNewMessageState extends State<AppwriteNewMessage> {
  final _controller = new TextEditingController();
  var _enterMessage = '';

  void _sendMessage() async {
//    var _chatAppwrite = Provider.of<ChatAppwrite>(context, listen: false);
    FocusScope.of(context).unfocus();
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    Firestore.instance.collection('chat').add({
      'text': _enterMessage,
      'username': userData['username'],
      'image_url': userData['image_url'],
      'createdAt': Timestamp.now(),
      'userId': user.uid,
    });
//    print('Get _chatAppwrite.getUserId() is ' + _chatAppwrite.getUserId());
//    print('Get _chatAppwrite.listUser() is ');
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(labelText: 'Send a message...'),
                onChanged: (value) {
                  setState(() {
                    _enterMessage = value;
                  });
                },
              ),
            ),
            IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.send),
                onPressed: _enterMessage.trim().isEmpty ? null : _sendMessage)
          ],
        ));
  }
}
