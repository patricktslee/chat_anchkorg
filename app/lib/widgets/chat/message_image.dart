import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

class MessageImage extends StatelessWidget {
  MessageImage(this.message, this.username, this.imageUrl, this.isMe,
      {this.key});

  final String message;
  final String username;
  final String imageUrl;
  final bool isMe;
  final Key key;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    void _showDialogByText(String message) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                RaisedButton.icon(
                  onPressed: () {
                    FlutterClipboard.copy(message);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  icon: Icon(Icons.copyright),
                  label: Text('Copy'),
                ),
              ],
            );
          });
    }

    return InkWell(
      child: Container(
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            isMe
                ? SizedBox(
                    height: mediaQuery.size.height * 0.007,
                  )
                : Text(
                    username,
                    style: TextStyle(
                        color: isMe
                            ? Colors.black
                            : Theme.of(context).accentTextTheme.headline1.color,
                        fontWeight: FontWeight.bold),
                  ),
            Image(
              image: NetworkImage(imageUrl),
              fit: BoxFit.fill,
              width: mediaQuery.size.width * 0.6,
            ),
          ],
        ),
      ),
      onTap: () {
        _showDialogByText(message);
      },
    );
  }
}
