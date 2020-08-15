import 'dart:async';

import 'package:chat/model/chat_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Key;
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../config/metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appwrite/appwrite.dart';

class ChatAppwrite extends ChangeNotifier {
  Client appwriteClient = Client();
  Database database;
  Account account;
  Storage storage;
  String appWriteServerUrl = Metadata.appWriteServerUrl;
  String _projectId = Metadata.projectId;
  String _collectionIdUsers = Metadata.collectionIdUsers;
  String _chatCollectionId = Metadata.chatCollectionId;
  String _userId;
  String _userEmail;
  String _userPassword;
  bool _isLogin = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;
  FlStreamController<bool> loadingStreamController = FlStreamController();

  List<ChatModel> _chatList = [];

  List<ChatModel> get totalChatList => _chatList;

  Future<void> init() async {
    print('Initial the Chat AppWrite');
    appwriteClient
        .setEndpoint(appWriteServerUrl)
        .setProject(_projectId)
        .setSelfSigned();
    account = Account(appwriteClient);
    database = Database(appwriteClient);
    storage = Storage(appwriteClient);
    _userId = null;
    prefs = await _prefs;
    _isLogin = prefs.getBool('isLogin');
    print("isLogin after Prefs is $_isLogin");
    _userPassword = prefs.getString('_userPassword');

    _isLogin
        ? account
            .createSession(
                email: prefs.getString('_userEmail'), password: _userPassword)
            .then((value) => loadingStreamController.setData(_isLogin))
        : loadingStreamController.setData(_isLogin);
  }

  //signup
  // ignore: missing_return
  Future<String> signup(
      {@required String username,
      @required String password,
      @required String email,
      @required File file}) async {
    String _userid;
    print("Starting Signup====================");
    prefs.setBool('isLogin', _isLogin);
    loadingStreamController.setData(_isLogin);
    Future result = account.create(
      name: username,
      email: email,
      password: password,
    );
    result.then((response) {
      getChatData();
      print("create account success====================");
      print(response.toString());
      print(response.data['\$id']);
      _userid = response.data['\$id'];
      print("Trying to login");
      account
          .createSession(email: email, password: password)
          .then((createSessionValue) {
        print("Login success==================== ");
        String _filename = _userid + '.jpg';
        account.get().then((response) async {
          print("Get login success====================");
          print(response.data['name']);
          MediaType contentType = MediaType('image', 'jpg');
          Future createFileResult = storage.createFile(
            file: await MultipartFile.fromFile(file.path,
                filename: _filename, contentType: contentType),
            read: ['*'],
            write: [],
          );
          createFileResult.then((createFileResultResponse) {
            print("success====================");
            print(createFileResultResponse.toString());
            print('createFileResultResponse.data id is ' +
                createFileResultResponse.data['\$id']);
            String _fileId = createFileResultResponse.data['\$id'];
            createUser(
              username: response.data['name'],
              email: email,
              imageUrl:
                  '$appWriteServerUrl/storage/files/$_fileId/view?project=$_projectId',
            );
            _isLogin = true;
            _userEmail = email;
            _userPassword = password;
            print('IsLogin is $_isLogin');
            prefs.setBool('isLogin', _isLogin);
            prefs.setString('_userEmail', _userEmail);
            prefs.setString('_userPassword', _userPassword);
            loadingStreamController.setData(_isLogin);
          }).catchError((error) {
            print("result error====================");
            print(error.toString());
          });
        });
      }).catchError((error) {
        print("Login account error====================");
        print(error);
      });
      return _userid;
    }).catchError((error) {
      print("create account error====================");
      print(error.toString());
      prefs.setBool('isLogin', _isLogin);
      prefs.setString('_userEmail', _userEmail);
      prefs.setString('_userPassword', _userPassword);
      loadingStreamController.setData(_isLogin);
      return 'error';
    });
  }

  Future<dynamic> login(
      {@required String email, @required String password}) async {
    print("Trying Login====================");
    prefs.setBool('isLogin', _isLogin);
    loadingStreamController.setData(_isLogin);
    Future result = account.createSession(
      email: email,
      password: password,
    );

    result.then((response) {
      getChatData();
      getUserInfo();
      print("success====================");
      print(response.toString());
      _isLogin = true;
      _userEmail = email;
      _userPassword = password;

      prefs.setBool('isLogin', _isLogin);
      prefs.setString('_userEmail', _userEmail);
      prefs.setString('_userPassword', _userPassword);
      loadingStreamController.setData(_isLogin);
      return response;
    }).catchError((error) {
      print("error====================");
      print(error.toString());
      prefs.setBool('isLogin', _isLogin);
      prefs.setString('_userEmail', _userEmail);
      prefs.setString('_userPassword', _userPassword);
      loadingStreamController.setData(_isLogin);
      return error;
    });
  }

  getUserSession() {
    print("Trying Login====================");
    Future result = account.getSessions();

    result.then((response) {
      print("Trying Login success===================");
      print(response);
    }).catchError((error) {
      print("Trying Login error===================");
      print(error.response);
    });
  }

  loginWithGoogle() async {
    await account.createOAuth2Session(
        provider: 'google', success: 'success', failure: 'failed');
  }

  loginWithFb() async {
    await account.createOAuth2Session(
        provider: 'facebook', success: 'success', failure: 'failed');
  }

  logout() {
    print("logout----------");
    Future result = account.deleteSessions();

    result.then((response) {
      print("success====================");
      print(response);
      _isLogin = false;
      _userEmail = '';
      _userPassword = '';
      prefs.setBool('isLogin', _isLogin);
      prefs.setString('_userEmail', _userEmail);
      prefs.setString('_userPassword', _userPassword);
      loadingStreamController.setData(_isLogin);
    }).catchError((error) {
      print("error====================");
      prefs.setBool('isLogin', _isLogin);
      prefs.setString('_userEmail', _userEmail);
      prefs.setString('_userPassword', _userPassword);
      loadingStreamController.setData(_isLogin);
      print(error);
    });
  }

  createUser({
    @required String username,
    @required String email,
    @required String imageUrl,
  }) {
    dynamic _data;
    _data = {
      "username": username,
      'email': email,
      'imageUrl': imageUrl,
    };
    Future result = database.createDocument(
      collectionId: _collectionIdUsers,
      data: _data,
      read: ['*'],
      write: ['*'],
    );

    result.then((response) {
      print("create user in Users database success====================");
      print(response.toString());
    }).catchError((error) {
      print("create user in Users database error====================");
      print(error.response);
    });
  }

  listUser() {
    Future result = database.listDocuments(
      collectionId: _collectionIdUsers,
    );

    result.then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
    });
  }

  getUser(String currentUserDocumentId) {
    Future result = database.getDocument(
      collectionId: _collectionIdUsers,
      documentId: currentUserDocumentId,
    );

    result.then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
    });
  }

  Stream<bool> getLoginStatus() {
    return Stream<bool>.value(_isLogin);
  }

  createFile(
      {@required File file,
      @required List read,
      @required List write,
      String filename}) async {
    String basename;
    (filename == null)
        ? basename = path.basename(file.path)
        : basename = filename;
    MediaType contentType = MediaType('image', 'jpg');
    Future result = storage.createFile(
      file: await MultipartFile.fromFile(file.path,
          filename: basename, contentType: contentType),
      read: ['*'],
      write: [],
    );
    result.then((response) {
      print("success====================");
      print(response.toString());
      print('response.data id is ' + response.data['\$id']);
    }).catchError((error) {
      print("result error====================");
      print(error.toString());
    });
  }

  addChatData({ChatModel chatModel, String userId}) {
    appwriteClient.setProject(_projectId);
    Future result = database.createDocument(
      collectionId: '$_chatCollectionId',
      data: chatModel.toJson(),
      read: ['*'],
      write: ['$_userId'],
    );

    result.then((response) {
      log('Create document: ' + response.toString());

      getChatData(); //// Refresh document list
    }).catchError((error) {
      log('Create document: ' + error.toString());
    });
  }

  getChatData() {
    appwriteClient.setProject(_projectId);
    Future result = database.listDocuments(
      orderField: 'timestamp',
      orderType: OrderType.desc,
      collectionId: '$_chatCollectionId',
    );

    result.then((response) {
      log('Get getChatData: ' +
          jsonDecode(response.toString())['documents'].toString());
      _chatList = (jsonDecode(response.toString())['documents'] as List)
          .map((i) => ChatModel.fromJson(i))
          .toList();
      notifyListeners();
    }).catchError((error) {
      log('Get getChatData error: ' + error.toString());
    });
  }

  updateChatData({ChatModel noteModel, String userId}) {
    log(noteModel.toJson().toString());
    appwriteClient.setProject(_projectId);
    Future result = database.updateDocument(
      documentId: noteModel.id,
      collectionId: '$_chatCollectionId',
      data: noteModel.toJson(),
      read: ['*'],
      write: [
        '$_userId'
      ], //// Disclaim, everyone can write sine I set to '*' as just demo
    );
    result.then((response) {
      log('Update document: ' + response.toString());
      getChatData();
    }).catchError((error) {
      log('Update document: ' + error.toString());
    });
  }

  deleteChatData({ChatModel noteModel}) {
    appwriteClient.setProject(_projectId);
    Future result = database.deleteDocument(
      documentId: noteModel.id,
      collectionId: '$_chatCollectionId',
    );

    result.then((response) {
      log('Delete document: ' + response.toString());
      getChatData();
    }).catchError((error) {
      log('Delete document: ' + error.toString());
    });
  }

  getUserId() {
    return _userId;
  }

  getUserInfo() {
    log("accont prefs------");
    Future result = account.get();

    result.then((response) {
      print("getUserInfo Success====================");
      _userId = jsonDecode(response.toString())['roles'][1].toString();
      log(_userId);
      log(response.data.toString());
      print(response.data.toString());
      getChatData();
      notifyListeners();
    }).catchError((error) {
      print("getUserInfo error====================");
      log(error.toString());
    });
  }
}

class FlStreamController<T> {
  T _prevData;

  // Stream of data T to notify the T data change
  final StreamController<T> _dataController = StreamController.broadcast();

  Stream<T> get dataStream => _dataController.stream;

  void setData(T data) {
    if (_prevData != data) {
      _prevData = data;
      _dataController.add(data);
    }
  }
}

//enum ConnectionState {
//  /// Not currently connected to any asynchronous computation.
//  ///
//  /// For example, a [FutureBuilder] whose [FutureBuilder.future] is null.
//  none,
//
//  /// Connected to an asynchronous computation and awaiting interaction.
//  waiting,
//
//  /// Connected to an active asynchronous computation.
//  ///
//  /// For example, a [Stream] that has returned at least one value, but is not
//  /// yet done.
//  active,
//
//  /// Connected to a terminated asynchronous computation.
//  done,
//}
