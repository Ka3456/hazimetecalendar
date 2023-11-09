import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hazimetecalendar/models/user.dart' as model;
import 'package:hazimetecalendar/resources/storage_method.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  // sign up userxyg
  Future<String> signUpUser({
    required String email, //email
    required String password, //password
    required String passwordcheck, //passwordの確認
    required String username, //username
    //required String uid,
    required Uint8List file, //プロフィールの画像
  }) async {
    String res = 'Some error occured';
    try {
      //パスワードの一致を確認
      if (password == passwordcheck) {
        //全ての欄を記入しているのかを確認
        if (email.isNotEmpty ||
            password.isNotEmpty ||
            username.isNotEmpty ||
            password.isNotEmpty ||
            passwordcheck.isNotEmpty) {
          //register user
          UserCredential cred = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);

          print(cred.user!.uid);

          String photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);

          // add user to our database

          model.User user = model.User(
            uid: cred.user!.uid,
            username: username,
            email: email,
            password: 'unavailable',
            passwordcheck: 'unavailable',
            followers: [],
            following: [],
            blocking: [],
            blocked: [],
            photoUrl: photoUrl,
          );

          await _firestore.collection('users').doc(cred.user!.uid).set(
                user.toJason(),
              );
          res = 'アカウント作成できました！';
          print('全てのデータのアップロードに成功');
        }
      } else {
        //パスワードが一致しない場合
        res = 'パスワードが一致しません';
      }
    } catch (err) {
      if (err.toString().contains('already in use')) {
        res = 'このメールアドレスは既に使われています';
      } else if (err
          .toString()
          .contains('The email address is badly formatted')) {
        res = 'メールアドレスの形式が正しくありません';
      } else if (err.toString().contains('An email address must be provided')) {
        res = 'メールアドレスを入力してください';
      } else {
        res = err.toString();
      }
    }
    return res;
  }

  //login in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //管理者を認識する
        if ((email == 'auth@gmail.com') & (password == 'authauth')) {
          await _auth.signInWithEmailAndPassword(
              email: email, password: password);
          res = 'authuser';
        } else {
          //通常のログイン
          await _auth.signInWithEmailAndPassword(
              email: email, password: password);
          res = 'success';
        }
      } else {
        res = '全ての欄を埋めてください';
      }
    } catch (err) {
      if (err.toString().contains('INVALID')) {
        res = 'メールアドレスかパスワードが間違っています';
      } else if (err.toString().contains('invalid')) {
        res = 'メールアドレスかパスワードが間違っています';
      } else {
        res = err.toString();
      }
    }

    return res;
  }

  //add news
  //addNews(_newsurl.text, _newstitle.text, _newimage.text);
  Future<void> addNews({
    required String newsurl,
    required String newstitle,
    required String newsimage,
  }) async {
    FirebaseFirestore.instance.collection('news').add({
      'news_url': newsurl,
      'news_title': newstitle,
      'news_image': newsimage,
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
