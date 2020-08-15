import 'package:chat/providers/chat_appwrite.dart';
import 'package:chat/screens/screens.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppwriteScreen extends StatefulWidget {
  @override
  _AppwriteScreenState createState() => _AppwriteScreenState();
}

class _AppwriteScreenState extends State<AppwriteScreen> {
  @override
  Widget build(BuildContext context) {
    var _chatAppwrite = Provider.of<ChatAppwrite>(context, listen: false);
    return StreamBuilder(
//        stream: FirebaseAuth.instance.onAuthStateChanged,
        stream: _chatAppwrite.loadingStreamController.dataStream,
        builder: (ctx, userSnapshot) {
          print('userSnapshot is ' + userSnapshot.data.toString());
          if (userSnapshot.data != null && userSnapshot.data) {
            return AppwriteChatScreen();
          }
//         if (userSnapshot.connectionState == ConnectionState.waiting) {
//           return SplashScreen();
//         }
//         if (userSnapshot.hasData) {
//           return AppwriteChatScreen();
//         }
          return AppwriteAuthScreen();
        });
  }
}
