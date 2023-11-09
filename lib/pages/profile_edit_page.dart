import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hazimetecalendar/pages/first_page.dart';
import 'package:hazimetecalendar/pages/root_page.dart';
import 'package:hazimetecalendar/pages/setting_page.dart';
import 'package:hazimetecalendar/provider/usr_provider.dart';
import 'package:hazimetecalendar/resources/firestore_method.dart';
import 'package:hazimetecalendar/utils/ImagePicker.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:hazimetecalendar/utils/colors.dart';
//import 'package:hazimetecalendar/utils/utils.dart';

class ProfileEditPage extends StatefulWidget {
  final String uid;
  const ProfileEditPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  bool isLoading = false;

  bool usernameeditor = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      print('エラー$e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    // userコレクションを削除
    final msg =
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    await user?.delete();
    await FirebaseAuth.instance.signOut();

    print('$userユーザーを削除しました!');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirstPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    //{password: 123456, following: [lM17RZuGcwbSUzey8YcBPh8GH6K2, 9QlbSnOrdGeTze8KT9rSL5H1QjE3, hYus1aYtHmgRJ0wQtZiw6EZBcTh2, Fdourgap4TdShX6PsHKNWfgNvYm1], uid: bvpl20uGawgKZ8Q554ZLwlKxzL53, followers: [9QlbSnOrdGeTze8KT9rSL5H1QjE3, hYus1aYtHmgRJ0wQtZiw6EZBcTh2, Fdourgap4TdShX6PsHKNWfgNvYm1], email: test02@gmail.com, photoUrl: https://firebasestorage.googleapis.com/v0/b/hazimete-calendar.appspot.com/o/profilePics%2Fbvpl20uGawgKZ8Q554ZLwlKxzL53?alt=media&token=c71d9bbb-e331-4c08-bb35-8bfd131bc8c6, username: test02, passwordcheck: 123456}
    print('userDataの中身は$userData');
    var _screenSize = MediaQuery.of(context).size;

    final picker = ImagePicker();
    Uint8List? _file;

    pickImage(ImageSource source) async {
      final ImagePicker _imagePicker = ImagePicker();

      XFile? _file = await _imagePicker.pickImage(source: source);

      if (_file != null) {
        return await _file.readAsBytes();
      }
      print('No image is selected.');
    }

    _selectImage(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(title: const Text('アイコンを選択'), children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('写真をとる'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.camera);

                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('写真を選択'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.gallery);

                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ]);
        },
      );
    }

    logout() async {
      try {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FirstPage()),
        );
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        showSnackBar(e.toString(), context);
      }
    }

    try {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.to(() => const MainPage());
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: lettercolor,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: mobileBackgroundColor,
          title: const Text('設定'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: mobileBackgroundColor,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white, // 白色の背景を指定

                          child: userData['photoUrl'].isEmpty
                              ? Image.asset(
                                  'assets/images/signup_logo_01.png',
                                  fit: BoxFit.fill,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(userData['photoUrl']),
                                      fit: BoxFit.fill,
                                      alignment: FractionalOffset.topCenter,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 270,
                      bottom: 0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttoncolor3,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0, // x座標を設定
                              top: -7.5, // y座標を設定
                              child: IconButton(
                                onPressed: () => _selectImage(context),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 画像が選択されていない場合は、テキストを表示
                    userData['photoUrl'].isNotEmpty
                        ? const SizedBox(height: 0)
                        : const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'プロフィール写真\n選択',
                              style: TextStyle(
                                color: lettercolor,
                                fontSize: 27,
                                //fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    width: _screenSize.width * 0.3,
                    child: const Text(
                      'ユーザー名',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    userData['username'],
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    width: _screenSize.width * 0.3,
                    child: const Text(
                      'メールアドレス',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    userData['email'],
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('確認'),
                        content: const Text('ログアウトしますか？',
                            style: TextStyle(fontSize: 20)),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('OK'),
                            onPressed: () {
                              logout();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('キャンセル'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('ログアウト'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('確認'),
                        content: const Text('退会しますか？',
                            style: TextStyle(fontSize: 20)),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('退会する'),
                            onPressed: () {
                              deleteUser();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('キャンセル'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('退会する'),
              ),
              ElevatedButton(
                onPressed: () {
                  //url_luncherでGoogleフォームを開く
                },
                child: const Text('お問い合わせ'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
