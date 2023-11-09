import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hazimetecalendar/provider/usr_provider.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class MakeCalendar extends StatefulWidget {
  const MakeCalendar({super.key});

  @override
  State<MakeCalendar> createState() => _MakeCalendarState();
}

class _MakeCalendarState extends State<MakeCalendar> {
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  String calendarname = '';
  String childname = '';
  String username = '';
  DateTime birthday = DateTime.now();
  final TextEditingController _calendarnameController = TextEditingController();
  final TextEditingController _childnameController = TextEditingController();

  var _labelText = 'Select Date';

  makecalendar(
    String calendarname,
    String childname,
    DateTime birthday,
  ) async {
    //calendarsにcalendaridを追加

    FirebaseFirestore.instance.collection('calendars').doc(calendarname).set({
      'calendarid': calendarname,
      'chilename': childname,
      'birthday': birthday,
      'edittingUserUid': [currentUserID],
      'watchingingUserUid': [],
    });

    //calendarに作成者情報を付与
    FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendarname)
        .collection('edittingUserUid')
        .doc()
        .set({'edittingUserUid': currentUserID});

    //userにcalendaridを追加
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .collection('calendarview')
        .doc()
        .set({
      'calendarid': calendarname,
    });

    print('カレンダー作成完了');
  }

  @override
  void dispose() {
    super.dispose();
    _calendarnameController.dispose();
    _childnameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('カレンダーを新規作成'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              width: size.width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                color: Colors.white,
              ),
              child: TextFieldInput(
                hintText: '子供の名前',
                textInputType: TextInputType.text,
                textEditingController: _childnameController,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2000, 1, 1),
                  maxTime: DateTime.now(), onChanged: (date) {
                birthday = date;
              }, onConfirm: (date) {
                birthday = date;
                setState(() {
                  _labelText = '${date.year}年${date.month}月${date.day}日';
                });
              }, currentTime: DateTime.now(), locale: LocaleType.jp);
            },
            child: const Text(
              '日付を選択',
              style: TextStyle(color: Colors.blue),
            ),
          ),
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
                childname = _childnameController.text;

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          '確認',
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              color: primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      content: Text(
                        '子供の名前：$childname\n誕生日：$_labelText',
                        style: TextStyle(fontSize: size.width * 0.05),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('OK'),
                          onPressed: () {
                            setState(() {
                              calendarname =
                                  DateTime(DateTime.now().millisecond)
                                      .toString();
                            });
                            makecalendar(calendarname, childname, birthday);
                            print('カレンダー名$calendarname');
                            Navigator.of(context).pop();
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

                //makecalendar(calendarname, childname, birthday);
              },
              // makecalendar(calendarname),
              child: const Text(
                '作成',
                style: TextStyle(
                    fontSize: 30,
                    color: buttoncolor,
                    fontWeight: FontWeight.w100),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.05),
        ],
      ),
    );
  }
}
