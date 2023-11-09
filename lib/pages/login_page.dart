import 'package:flutter/material.dart';

import 'package:hazimetecalendar/pages/first_page.dart';
import 'package:hazimetecalendar/pages/forgotpassword_page.dart';
import 'package:hazimetecalendar/pages/root_page.dart';
import 'package:hazimetecalendar/resources/auth_method.dart';
import 'package:hazimetecalendar/responsive/auth_page.dart';

import 'package:hazimetecalendar/utils/colors.dart';
import 'package:get/get.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String show_res = '';

  @override
  void dispose() {
    super.dispose();
    show_res = '';
    _emailController.dispose();
    _passwordController.dispose();
  }

  //管理者画面へ

  void adminLogin() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      show_res = res;
    });

    if (res == 'success') {
      Get.to(() => const MainPage());
    } else {
      //showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  //ログイン

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      show_res = res;
    });

    if (res == 'success') {
      Get.to(() => const MainPage());
    } else if (res == 'authuser') {
      Get.to(() => const AuthPage());
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
        child: Column(children: [
          const SizedBox(height: 100),
          const Text(
            'ログイン',
            style: TextStyle(fontSize: 50, color: lettercolor),
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
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Text(
                  'メールアドレス',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: lettercolor),
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
              ],
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                const Text(
                  'パスワード',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: lettercolor),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 250, //
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                    color: Colors.white,
                  ),
                  child: TextFieldInput(
                    hintText: 'パスワード',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true,
                  ),
                ),
                (show_res != '')
                    ? Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            show_res,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    : const SizedBox(height: 0),
              ],
            ),
          ),

          const SizedBox(height: 30), //入力欄の下のスペース

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ForgotPasswordPage();
                  },
                ),
              );
            },
            child: const Text(
              'パスワードをお忘れの場合',
              style: TextStyle(fontSize: 20, color: lettercolor),
            ),
          ),
          const SizedBox(height: 5),

          const SizedBox(height: 60),
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
                loginUser();
              },
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : const Text(
                      'ログイン',
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
                'アカウントをお持ちでない方',
                style: TextStyle(
                  color: blueColor,
                  fontSize: 15,
                ),
              )),

          SizedBox(
            child: Image.asset(
              'assets/images/login_logo_01.png',
              fit: BoxFit.fitWidth,
            ),
          ),
        ]),
      ),
    );
  }
}
