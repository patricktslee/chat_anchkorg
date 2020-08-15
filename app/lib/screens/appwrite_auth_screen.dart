import 'dart:io';

import 'package:chat/providers/chat_appwrite.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
//import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AppwriteAuthScreen extends StatefulWidget {
  @override
  _AppwriteAuthScreenState createState() => _AppwriteAuthScreenState();
}

class _AppwriteAuthScreenState extends State<AppwriteAuthScreen> {
  var _isLoading = false;
//  final _auth = FirebaseAuth.instance;
  void _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
//    AuthResult authResult;
    dynamic appwriteAuthResult;
    var _chatAppwrite = Provider.of<ChatAppwrite>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      print('isLoading is ' + _isLoading.toString());
      if (isLogin) {
//       authResult = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
        await _chatAppwrite.login(
          email: email,
          password: password,
        );
//        appwriteAuthResult.then((value) => print('appwriteAuthResult'));
//        setState(() {
//          _isLoading = false;
//        });
//        print('isLoading is ' + _isLoading.toString());
      } else {
//       authResult = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
        appwriteAuthResult = await _chatAppwrite.signup(
            username: username, password: password, email: email, file: image);
        print('appwriteAuthResult ' + appwriteAuthResult);
//      final ref = FirebaseStorage.instance
//          .ref()
//          .child('user_image')
//          .child(authResult.user.uid + '.jpg');
//      await ref.putFile(image).onComplete;
//      final url = await ref.getDownloadURL();
//
//      await Firestore.instance
//          .collection('users')
//          .document(authResult.user.uid)
//          .setData({
//        'username': username,
//        'email': email,
//        'image_url': url,
//      });
      }
    } on PlatformException catch (err) {
      var message = 'An error';
      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(children: <Widget>[
      Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: AuthForm(_submitAuthForm, _isLoading),
      ),
    ]);
  }
}
