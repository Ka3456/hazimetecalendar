import 'package:flutter/material.dart';
import 'package:hazimetecalendar/provider/usr_provider.dart';
import 'package:hazimetecalendar/resources/auth_method.dart';
import 'package:hazimetecalendar/widget/news_article.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _newsurl = TextEditingController();
  final TextEditingController _newimage = TextEditingController();
  final TextEditingController _newstitle = TextEditingController();
  addData() async {
    //特にこのコードが重要！！！！
    UserProvider _useProvider = Provider.of(context, listen: false);
    await _useProvider.refreshUser();
  }

  @override
  void initState() {
    super.initState();
    addData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理者画面'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 100),
          const Center(
            child: Text('管理者画面です'),
          ),

          TextFieldInput(
            hintText: 'ニュースurl',
            textInputType: TextInputType.text,
            textEditingController: _newsurl,
          ),
          TextFieldInput(
            hintText: 'imageurl',
            textInputType: TextInputType.text,
            textEditingController: _newimage,
          ),
          TextFieldInput(
            hintText: 'title',
            textInputType: TextInputType.text,
            textEditingController: _newstitle,
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _newsurl.text = _newsurl.text;
                _newimage.text = _newimage.text;
                _newstitle.text = _newstitle.text;
              });
            },
            child: const Text('デモを表示'),
          ),

          ((_newsurl.text).isNotEmpty &
                  (_newimage.text).isNotEmpty &
                  (_newstitle.text).isNotEmpty)
              ? Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ).copyWith(right: 0),
                        child: NewsPage(
                          news_url: _newsurl.text,
                          news_title: _newstitle.text,
                          news_image: _newimage.text,
                        )),
                    ElevatedButton(
                      onPressed: () {
                        AuthMethods().addNews(
                          newsurl: _newsurl.text,
                          newstitle: _newstitle.text,
                          newsimage: _newimage.text,
                        );
                      },
                      child: const Text('アップロード'),
                    ),
                  ],
                )
              : const Text('デモを表示するには、urlを入力してください'),

          //ログアウトボタン
          ElevatedButton(
            onPressed: () {
              //ログアウト
              //AuthMethods().signOut();
              Navigator.pop(context);
            },
            child: const Text('ログアウト'),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
