import 'package:flutter/material.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        title: const Text('パスワードを忘れた方'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.1),
            child: Text(
              '登録しているメールアドレスに\n新しいパスワードを送信します',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: size.width * 0.05,
                  color: lettercolor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: size.width * 0.05),
          Text(
            'メールアドレス',
            style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: lettercolor),
          ),
          SizedBox(height: size.width * 0.05),
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
          const SizedBox(height: 30),
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
                passwordReset();
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : Text(
                      'パスワードをリセット',
                      style: TextStyle(
                          fontSize: size.width * 0.065,
                          color: buttoncolor,
                          fontWeight: FontWeight.w100),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
