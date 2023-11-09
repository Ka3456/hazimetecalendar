import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hazimetecalendar/pages/first_page.dart';
import 'package:hazimetecalendar/pages/login_page.dart';
import 'package:hazimetecalendar/pages/root_page.dart';
import 'package:hazimetecalendar/resources/auth_method.dart';
import 'package:hazimetecalendar/utils/ImagePicker.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';

import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordcheckController =
      TextEditingController();
  String show_res = '';

  // Uint8List? _image;
  bool _isLoading = false;
  final picker = ImagePicker();
  Uint8List? _file;

  @override
  void dispose() {
    super.dispose();
    show_res = '';
    _emailController.dispose();
    _passwordController.dispose();
    _passwordcheckController.dispose();
    _usernameController.dispose();
  }

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

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      passwordcheck: _passwordcheckController.text,
      file: _file!,
    );
    setState(() {
      show_res = res;
    });

    if (res == 'アカウント作成できました！') {
      Get.to(() => const LoginScreen());
    } else {
      //showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'アカウント作成',
              style: TextStyle(
                color: lettercolor,
                fontSize: 40,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
              child: SizedBox(
                child: Image.asset(
                  'assets/images/login_logo_02.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Stack(
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

                      child: _file == null
                          ? Image.asset(
                              'assets/images/signup_logo_01.png',
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
                          left: -7.5, // x座標を設定
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
                (_file != null)
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
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  const SizedBox(width: 20),
                  const Text(
                    'ユーザーネーム',
                    style: TextStyle(
                        color: lettercolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10), // テキストと入力欄の間隔を調整
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                      color: Colors.white,
                    ),
                    child: TextFieldInput(
                        hintText: ' ユーザー名',
                        textInputType: TextInputType.text,
                        textEditingController: _usernameController),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const SizedBox(width: 20),
                  const Text(
                    'メールアドレス',
                    style: TextStyle(
                        color: lettercolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                      color: Colors.white,
                    ),
                    child: TextFieldInput(
                      hintText: ' メールアドレス',
                      textInputType: TextInputType.emailAddress,
                      textEditingController: _emailController,
                    ),
                  ),

                  const SizedBox(width: 10), // テキストと入力欄の間隔を調整
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const SizedBox(width: 20),
                  const Text(
                    'パスワード',
                    style: TextStyle(
                        color: lettercolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                      color: Colors.white,
                    ),
                    child: TextFieldInput(
                      hintText: ' パスワード',
                      textInputType: TextInputType.text,
                      textEditingController: _passwordController,
                      isPass: true,
                    ),
                  ),

                  const SizedBox(width: 10), // テキストと入力欄の間隔を調整
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    'パスワード(確認)',
                    style: TextStyle(
                        color: lettercolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10), // テキストと入力欄の間隔を調整
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                      color: Colors.white,
                    ),
                    child: TextFieldInput(
                      hintText: ' パスワード(確認)',
                      textInputType: TextInputType.text,
                      textEditingController: _passwordcheckController,
                      isPass: true,
                    ),
                  ),

                  const SizedBox(height: 10), // テキストと入力欄の間隔を調整
                ],
              ),
            ),
            (show_res == '')
                ? const SizedBox(height: 0)
                : const SizedBox(height: 0),
            Text(
              show_res!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: elevatecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(230, 60), // ボタンの縦横サイズを指定
                ),
                onPressed: () {
                  signUpUser();
                },
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : const Text(
                        '登録',
                        style: TextStyle(
                            fontSize: 30,
                            color: buttoncolor,
                            fontWeight: FontWeight.w100),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  Get.to(() => const FirstPage());
                },
                child: const Text(
                  'アカウントをお持ちの方',
                  style: TextStyle(color: blueColor, fontSize: 15),
                )),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
