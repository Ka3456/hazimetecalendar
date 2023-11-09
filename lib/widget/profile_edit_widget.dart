import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hazimetecalendar/pages/profile_edit_page.dart';
import 'package:hazimetecalendar/resources/storage_method.dart';

import 'package:hazimetecalendar/utils/colors.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditWidget extends StatefulWidget {
  var userData;
  ProfileEditWidget({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProfileEditWidget> createState() => _ProfileEditWidgetState();
}

class _ProfileEditWidgetState extends State<ProfileEditWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool passwordisok = false;
  bool _isLoading = false;
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
              Uint8List file = await pickImage(ImageSource.camera);

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
              Uint8List file = await pickImage(ImageSource.gallery);

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

  Future passwordReset() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('パスワードリセット'),
              content: Text('パスワードのリセットメールを送信しました。'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
    } on FirebaseAuthException catch (e) {
      print('パスワードリセットエラー$e');
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('エラー'),
              content: const Text('メールアドレスが間違っています。'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void updateUser() async {
    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData['uid'])
        .update({
      'username': _usernameController.text.trim(),
    }).then((value) {
      return 'アカウント作成できました！';
    }).catchError((err) {
      return err.toString();
    });

    if (_file != null) {
      Uint8List file = _file!;

      //画像のアップデート
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', file, false);

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData['uid'])
          .update({
        'photoUrl': photoUrl,
      }).then((value) {
        print('画像のアップデートに成功しました');
      }).catchError((err) {
        print('画像のアップデートに失敗しました');
      });
    }

    setState(() {
      _isLoading = false;
    });
    Get.to(() => ProfileEditPage(
          uid: FirebaseAuth.instance.currentUser!.uid,
        ));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print('い、成功');
    _usernameController.text = widget.userData['username'];

    //{password: unavailable, following: [], blocking: [], uid: 2Ec4el0YFeSMqLu2IvPfkYmvQTD3, followers: [], email: test34@gmail.com, blocked: [VewnbHG6Z0fhbH22YCzuDoAWKFS2], photoUrl: https://firebasestorage.googleapis.com/v0/b/hazimete-calendar.appspot.com/o/profilePics%2F2Ec4el0YFeSMqLu2IvPfkYmvQTD3?alt=media&token=f6a945bb-c251-438f-9854-f330b56bf657, username: TTT, passwordcheck: unavailable}

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('プロフィールを編集'),
      ),
      body: //Center(child: Text(widget.userData['username'])));
          Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.05),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
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

                    child: _file == null
                        ? Image(
                            image: NetworkImage(widget.userData['photoUrl']),
                            fit: BoxFit.fill,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(_file!),
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              //
              Positioned(
                left: size.width * 0.35,
                bottom: 0,
                child: Container(
                  width: size.width * 0.13,
                  height: size.width * 0.13,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttoncolor3,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -size.width * 0.015,
                        bottom: -size.width * 0.015,
                        child: IconButton(
                          onPressed: () => _selectImage(context),
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: size.width * 0.13,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //
            ],
          ),
          const SizedBox(height: 60),

          // ユーザー名

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: size.width * 0.1),
              SizedBox(
                  width: size.width * 0.4,
                  child: Text(
                    'ユーザー名 :',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.height * 0.02,
                    ),
                  )),
              Container(
                width: size.width * 0.4,
                //height: size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                  color: Colors.white,
                ),
                child: TextFormField(
                  controller: _usernameController,

                  //initialValue: widget.userData['username'],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.userData['username'],
                  ),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: size.width * 0.01),
            ],
          ),
          const Divider(
            color: Colors.black,
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          SizedBox(height: size.height * 0.01),

          // メールアドレス
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: size.width * 0.1),
              SizedBox(
                width: size.width * 0.4,
                height: size.height * 0.05,
                child: Column(
                  children: [
                    Text(
                      'メールアドレス :',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.height * 0.02,
                      ),
                    ),
                    Text(
                      '（変更不可）',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: size.height * 0.01,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: size.width * 0.4,
                height: size.height * 0.05,
                child: Column(
                  children: [
                    Text(
                      widget.userData['email'],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '（変更不可）',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: size.height * 0.01,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.01),
            ],
          ),
          const Divider(
            color: Colors.black,
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          // パスワードAleartDialog
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Container(
                            child: Column(
                          children: [
                            Text(
                              'パスワードを変更する',
                              style: TextStyle(fontSize: size.width * 0.08),
                            ),
                            Text(
                              '（メールアドレスにリセットメールを送信します）',
                              style: TextStyle(fontSize: size.width * 0.05),
                            ),
                          ],
                        )),
                        content: Container(
                            width: size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10), // 角丸の程度を指定
                              color: Colors.white,
                            ),
                            child: Text(widget.userData['email'])),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('キャンセル')),
                          TextButton(
                              onPressed: () {
                                passwordReset();
                              },
                              child: const Text('変更する')),
                        ],
                      );
                    });
              },
              child: Container(
                child: const Text('パスワードを変更する'),
              )),

          //更新ボタン
          SizedBox(height: size.height * 0.05),

          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: elevatecolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fixedSize:
                    Size(size.width * 0.8, size.width * 0.2), // ボタンの縦横サイズを指定
              ),
              onPressed: () {
                setState(() {
                  _usernameController;
                });
                updateUser();
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : Text(
                      'プロフィールを変更',
                      style: TextStyle(
                          fontSize: size.width * 0.065,
                          color: buttoncolor,
                          fontWeight: FontWeight.w100),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
