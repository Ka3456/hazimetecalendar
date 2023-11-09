import 'package:flutter/material.dart';
import 'package:hazimetecalendar/pages/login_page.dart';
import 'package:hazimetecalendar/pages/signup_page.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:get/get.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity, // 横幅を最大に設定
        height: double.infinity, // 高さを最大に設定
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/first_logo_background.png'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 237, 163, 188), // 上部の色
              Colors.white, // 下部の色
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100), // 初期設定のため大幅に枠を作る

            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
              child: Image.asset(
                'assets/images/first_logo_01.png',
                fit: BoxFit.fitWidth,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              child: Image.asset(
                width: double.infinity,
                'assets/images/first_logo_00.png',
                fit: BoxFit.fitWidth,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elevatecolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: const Size(230, 60), // ボタンの縦横サイズを指定
                  ),
                  onPressed: () {
                    Get.to(() => const LoginScreen());
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                    */
                  },
                  child: const Text(
                    'ログイン',
                    style: TextStyle(
                        fontSize: 30,
                        color: buttoncolor,
                        fontWeight: FontWeight.w100),
                  ),
                ),
              ),
            ),
            //ログインと新規登録の画面の間

            Expanded(
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 225, 235),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fixedSize: const Size(230, 60), // ボタンの縦横サイズを指定
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    '新規登録',
                    style: TextStyle(
                        fontSize: 30,
                        color: buttoncolor,
                        fontWeight: FontWeight.w100),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}
