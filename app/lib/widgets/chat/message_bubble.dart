import 'package:flutter/material.dart';
import './message_text.dart';
import './message_image.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(this.message, this.username, this.imageUrl, this.isMe,
      {this.key});

  final String message;
  final String username;
  final String imageUrl;
  final bool isMe;
  final Key key;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isImage = false;
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.green.withOpacity(0.5)
                    : Theme.of(context).accentColor.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                  bottomRight: !isMe ? Radius.circular(12) : Radius.circular(0),
                ),
              ),
              width: mediaQuery.size.width * 0.6,
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 8,
              ),
              child: isImage
                  ? MessageImage(message, username, imageUrl, isMe)
                  : MessageText(message, username, imageUrl, isMe),
            )
          ],
        ),
        Positioned(
          left: isMe ? null : (mediaQuery.size.width * 0.6) * 0.95,
          right: isMe ? (mediaQuery.size.width * 0.6) * 0.95 : null,
          child: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
      ],
      overflow: Overflow.visible,
    );
  }
}
