import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:hazimetecalendar/widget/calendar_edit_widget.dart';
import 'package:get/get.dart';

class CalendarEditor extends StatefulWidget {
  const CalendarEditor({super.key});

  @override
  State<CalendarEditor> createState() => _CalendarEditorState();
}

class _CalendarEditorState extends State<CalendarEditor> {
  bool isvisible = false;
  //ユーザー設定
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  List<String> calendarList = [];
  List calendarListData = [];

  List<String> edittingUserUidcalendarList = [];
  List edittingUserUidcalendarListData = [];

  List<String> followingList = [];
  List followingListData = [];

  showcalendar() async {
    if (mounted) {
      var followingListDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID.toString())
          .collection('calendarview')
          .get();

      if (followingListDocument.docs.isNotEmpty) {
        for (int i = 0; i < followingListDocument.docs.length; i++) {
          calendarList.add(followingListDocument.docs[i].data()['calendarid']);
        }
        //print('calendarList：$calendarList');
      } else {
        print('フォロワーがいません');
      }

      setState(() {
        calendarList;
      });
      showcalendarKeysDataFromUserCollection(calendarList);
    } else {
      print('処理は実行されませんでした');
    }
  }

  showcalendarKeysDataFromUserCollection(List<String> keysList) async {
    var calendarDocument =
        await FirebaseFirestore.instance.collection('calendars').get();

    for (int i = 0; i < calendarDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((calendarDocument.docs[i].data() as dynamic)['calendarid']) ==
            keysList[k]) {
          calendarListData.add(calendarDocument.docs[i].data());
        }
      }
    }
    //print('calendarListData$calendarListData');

    setState(() {
      calendarListData;
    });
  }

  showfollower() async {
    //followingList = [];

    var followingListDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID.toString())
        .collection('following')
        .get();
    //print('現在のユーザー名：$currentUserID');

    if (followingListDocument.docs.length > 0) {
      for (int i = 0; i < followingListDocument.docs.length; i++) {
        followingList.add(followingListDocument.docs[i].data()['uid']);
      }
      //print('フォロワー：$followingList');
    } else {
      //print('フォロワーがいません');
    }

    setState(() {
      followingList;
    });
    followersKeysDataFromUserCollection(followingList);
  }

  followersKeysDataFromUserCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection('users').get();

    for (int i = 0; i < allUsersDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((allUsersDocument.docs[i].data() as dynamic)['uid']) ==
            keysList[k]) {
          followingListData.add(allUsersDocument.docs[i].data());
        }
      }
    }

    setState(() {
      followingListData;
    });

    //print('followingListData: $followingListData');
  }

  //Useruidからユーザーの情報を取得する関数
  showUserdata(String useruid) async {
    var userDocument =
        await FirebaseFirestore.instance.collection('users').doc(useruid).get();

    return userDocument.data();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showcalendar();
    showfollower(); //followingListDataにユーザー名を保存
  }

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;

    //print('フォローイング$followingListData');
    //print('カレンダー$calendarListData');
    print('注目！！！');
    //print(calendarListData[0]);

    //calendarListData[index]['edittingUserUid']

// matchingUsersリストに一致する要素が格納される

    try {
      return calendarListData.length == 0
          ? Scaffold(
              backgroundColor: mobileBackgroundColor,
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
              ),
              body: const Center(
                child: Text('カレンダーがありません'),
              ))
          : Scaffold(
              backgroundColor: mobileBackgroundColor,
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: List.generate(calendarListData.length, (index) {
                    print(calendarListData[index]['watchingingUserUid']);
                    return Padding(
                      padding: EdgeInsets.only(
                        top: _screenSize.height * 0.03,
                        bottom: _screenSize.height * 0.03,
                        left: _screenSize.height * 0.03,
                        right: _screenSize.height * 0.03,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: _screenSize.height * 0.03,
                                        top: _screenSize.height * 0.03,
                                        bottom: _screenSize.height * 0.03,
                                        left: _screenSize.height * 0.03),
                                    child: Text(
                                      calendarListData[index]['chilename'],
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: _screenSize.height * 0.03),
                                    ),
                                  ),
                                ]),
                            Column(
                              children: [
                                Text('閲覧者',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: _screenSize.height * 0.02)),
                                SizedBox(
                                  height: _screenSize.height * 0.04,
                                ),
                              ],
                            ),

                            //カレンダー閲覧者をcalendarListData[index]['watchingUserUid']

                            if (calendarListData[index]['watchingingUserUid']
                                    .length ==
                                0)
                              SizedBox(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: _screenSize.height * 0.03),
                                child: Text(
                                  '閲覧者はいません',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _screenSize.height * 0.02),
                                ),
                              ))
                            else
                              for (int i = 0;
                                  i <
                                      calendarListData[index]
                                              ['watchingingUserUid']
                                          .length;
                                  i++)
                                FutureBuilder(
                                    future: showUserdata(calendarListData[index]
                                        ['watchingingUserUid'][i]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        return Padding(
                                          padding: EdgeInsets.all(
                                            _screenSize.height * 0.03,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 252, 216, 228),
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                //AlertDialogを表示する
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text('確認'),
                                                        content: Text(
                                                            '${snapshot.data['username']} さんを閲覧者から削除しますか？',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20)),
                                                        actions: <Widget>[
                                                          ElevatedButton(
                                                            child: const Text(
                                                                '削除'),
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(snapshot
                                                                      .data![
                                                                          'uid']
                                                                      .toString())
                                                                  .collection(
                                                                      'calendarview')
                                                                  .where(
                                                                      'calendarid',
                                                                      isEqualTo:
                                                                          calendarListData[index]
                                                                              [
                                                                              'calendarid'])
                                                                  .get()
                                                                  .then(
                                                                      (snapshot) {
                                                                snapshot
                                                                    .docs
                                                                    .first
                                                                    .reference
                                                                    .delete();
                                                              });
                                                              //カレンダーからも削除
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'calendars')
                                                                  .doc(calendarListData[
                                                                              index]
                                                                          [
                                                                          'calendarid']
                                                                      .toString())
                                                                  .update({
                                                                'watchingingUserUid':
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  snapshot
                                                                      .data![
                                                                          'uid']
                                                                      .toString()
                                                                ])
                                                              });
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            child: const Text(
                                                                'キャンセル'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  //ユーザーのアイコン
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          _screenSize.height *
                                                              0.03,
                                                      top: _screenSize.height *
                                                          0.03,
                                                      bottom:
                                                          _screenSize.height *
                                                              0.03,
                                                      left: _screenSize.height *
                                                          0.03,
                                                    ),
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              snapshot.data[
                                                                  'photoUrl']),
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          _screenSize.height *
                                                              0.03,
                                                      top: _screenSize.height *
                                                          0.03,
                                                      bottom:
                                                          _screenSize.height *
                                                              0.03,
                                                      left: _screenSize.height *
                                                          0.03,
                                                    ),
                                                    child: Text(
                                                      snapshot.data['username'],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: _screenSize
                                                                  .height *
                                                              0.03),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    })
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
    } catch (e) {
      print(e);
      return Scaffold(
          backgroundColor: mobileBackgroundColor,
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
          ),
          body: const Center(
            child: Text('カレンダーがありません'),
          ));
    }
  }
}
