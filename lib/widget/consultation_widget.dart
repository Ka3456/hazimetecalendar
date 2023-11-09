import 'package:flutter/material.dart';

class ConsultationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Row(
            children: [
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  '医師に相談しませんか？',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 100,
                height: 200,
                child: Image.asset(
                  'assets/images/hospital_img.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20),
              const Flexible(
                child: Text(
                  'はじめてカレンダーではチャットサービスを利用することで専門の医師に直接相談できます。お気軽にご相談ください',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          //ボタンの上の余白
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // ボタンが押されたときの処理
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 122, 188, 242),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 8,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  '医師に相談してみる',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class AskAround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Row(
            children: [
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  '気軽に相談しませんか？',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 100,
                height: 200,
                child: Image.asset(
                  'assets/images/dada_kosodate_komaru_woman.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20),
              const Flexible(
                child: Text(
                  '同じ悩みを抱えている人に相談して見ませんか？\n子育ての先輩にアドバイスをもらいましょう',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          //ボタンの上の余白
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // ボタンが押されたときの処理
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 122, 188, 242),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 8,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  '周りの人に相談してみる',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class OtherServicesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'その他のサービス',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'さまざまなサービスを提供しています。',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
