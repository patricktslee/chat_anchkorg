import 'package:chat/providers/chat_appwrite.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/chat/messages.dart';
import '../widgets/chat/new_message.dart';

class AppwriteChatScreen extends StatefulWidget {
  @override
  _AppwriteChatScreenState createState() => _AppwriteChatScreenState();
}

class _AppwriteChatScreenState extends State<AppwriteChatScreen> {
  @override
  void initState() {
    super.initState();
    //  final fbm = FirebaseMessaging();
    //  fbm.requestNotificationPermissions();
    //  fbm.configure();
    //  fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    var _chatAppwrite = Provider.of<ChatAppwrite>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    double sizedBoxWidth;
    sizedBoxWidth = (mediaQuery.size.width / 100);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          actions: <Widget>[
            DropdownButton(
                underline: Container(),
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
                items: [
                  DropdownMenuItem(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.exit_to_app),
                          SizedBox(width: sizedBoxWidth),
                          Text('Logout'),
                        ],
                      ),
                    ),
                    value: 'logout',
                  ),
                ],
                onChanged: (itemIdentifier) {
                  if (itemIdentifier == 'logout') {
//                    FirebaseAuth.instance.signOut();
                    _chatAppwrite.logout();
                  }
                })
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(child: Messages()),
              NewMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
