import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hazimetecalendar/pages/setting_page.dart';
import 'package:hazimetecalendar/pages/setting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hazimetecalendar/provider/usr_provider.dart';
import 'package:hazimetecalendar/utils/ImagePicker.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';
import 'package:provider/provider.dart';

class CalendarShare extends StatefulWidget {
  final String uid;
  const CalendarShare({super.key, required this.uid});

  @override
  State<CalendarShare> createState() => _CalendarShareState();
}

class _CalendarShareState extends State<CalendarShare> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  String res = '';

  bool isLoading = false;

  bool usernameeditor = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//////以前のもの
  //ユーザー設定
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  String calendarid = '';
  String useruid = '';

  final TextEditingController _searchuserController = TextEditingController();

  String selectname = '';
  String selectuid = '';
  List selectwatchingUserUid = [];

  bool isLikeSentClicked = true;
  //List<String> following = [];
  //List<String> followers = [];
  List likesList = [];

  List<String> searchUserList = [];
  List searchUserData = [];
  List<String> followingList = [];
  List followingListData = [];

  List<String> calendarList = [];
  List calendarListData = [];

  Future showcalendar() async {
    isLoading = true;
    List<String> calendarList = [];
    List calendarListData = [];
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
    isLoading = false;
  }

  Future showcalendarKeysDataFromUserCollection(List<String> keysList) async {
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

  //Userの検索
  searchUser([blockedlistuseruid]) async {
    var searchUserDocument = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _searchuserController.text)
        .get();

    if (searchUserDocument.docs.length == 0) {
      searchUserDocument = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _searchuserController.text)
          .get();
    }

    if (searchUserDocument.docs.length > 0) {
      //print(searchUserDocument.docs[0].data());

      for (int i = 0; i < searchUserDocument.docs.length; i++)
        searchUserList.add(searchUserDocument.docs[i].data()['uid']);
      //print('見つけたユーザー：$searchUserList');
    } else {
      //print('ユーザーが見つかりませんでした');
    }

    //blockedlistuseruidに含まれているuidをsearchUserListから削除
    if (blockedlistuseruid != null) {
      for (int i = 0; i < blockedlistuseruid.length; i++) {
        if (searchUserList.contains(blockedlistuseruid[i])) {
          searchUserList.remove(blockedlistuseruid[i]);
        }
      }
    }

    setState(() {
      searchUserList;
    });

    searchKeysDataFromUserCollection(searchUserList);
  }

  searchKeysDataFromUserCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection('users').get();

    for (int i = 0; i < allUsersDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((allUsersDocument.docs[i].data() as dynamic)['uid']) ==
            keysList[k]) {
          searchUserData.add(allUsersDocument.docs[i].data());
        }
      }
    }

    setState(() {
      searchUserData;
    });

    //print('searchUserData: $searchUserData');
  }

  //followingの結果を表示

  Future showfollower() async {
    followingList = [];

    var followingListDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID.toString())
        .get();

    for (int i = 0; i < followingListDocument['following'].length; i++) {
      followingList.add(followingListDocument['following'][i]);
    }

    setState(() {
      followingList;
    });
    //print('followingList:$followingList');
    followersKeysDataFromUserCollection(followingList);
    //followingList:[Fdourgap4TdShX6PsHKNWfgNvYm1, lM17RZuGcwbSUzey8YcBPh8GH6K2, hYus1aYtHmgRJ0wQtZiw6EZBcTh2]
  }

  Future followersKeysDataFromUserCollection(List<String> keysList) async {
    var allUsersDocument =
        await FirebaseFirestore.instance.collection('users').get();
    print('い、成功');

    for (int i = 0; i < allUsersDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((allUsersDocument.docs[i].data() as dynamic)['uid']) ==
            keysList[k]) {
          followingListData.add(allUsersDocument.docs[i].data());
        }
      }
    }
    print('ろ、成功');

    setState(() {
      followingListData;
    });
    print('は、成功');

    //print('followingListData: $followingListData');
  }

  //sharecalendarを実施
  sharecalendar(String selectedcalendarid, String useruid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(useruid)
        .collection('calendarwatching')
        .doc()
        .set({
      'calendarid': selectedcalendarid,
    });

    //カレンダーにも追加

    FirebaseFirestore.instance
        .collection('calendars')
        .doc(selectedcalendarid)
        .update({
      'watchingingUserUid': FieldValue.arrayUnion([useruid])
    });
  }

  unsharecalendar(String selectedcalendarid, String useruid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(useruid)
        .collection('calendarwatching')
        .where('calendarid', isEqualTo: selectedcalendarid)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });

    //カレンダーからも削除
    FirebaseFirestore.instance
        .collection('calendars')
        .doc(selectedcalendarid)
        .update({
      'watchingingUserUid': FieldValue.arrayRemove([useruid])
    });
  }

  /*コピペしてきた
  Future<void> watchingUser(String calendarid, String useruid) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('calendars')
          .doc(calendarid)
          .get();
      List watchinging = (snap.data()! as dynamic)['watchingingUserUid'];
      print('検出$watchinging');

      //既に閲覧できているときはwatchingUserUidから削除

      if (watchinging.contains(calendarid)) {
        await FirebaseFirestore.instance
            .collection('calendars')
            .doc(calendarid)
            .update({
          'watchingingUserUid': FieldValue.arrayRemove([useruid])
        });

        await FirebaseFirestore.instance
            .collection('calendars')
            .doc(calendarid)
            .update({
          'watchingingUserUid': FieldValue.arrayRemove([useruid])
        });
      }
      //まだ閲覧していなときはwatchingUserUidに追加
      else {
        await FirebaseFirestore.instance
            .collection('calendars')
            .doc(calendarid)
            .update({
          'watchingingUserUid': FieldValue.arrayUnion([useruid])
        });

        await FirebaseFirestore.instance
            .collection('calendars')
            .doc(calendarid)
            .update({
          'watchingingUserUid': FieldValue.arrayUnion([useruid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  */

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

  //フォローする
  addfollowing(String followinguid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .update({
        'following': FieldValue.arrayUnion([followinguid])
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(followinguid)
          .update({
        'followers': FieldValue.arrayUnion([currentUserID])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchuserController.dispose();

    followingListData.clear();
  }

  @override
  void initState() {
    super.initState();
    getData();
    showcalendar();
    showfollower();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    print('実行');

    /*

    if (followingListData.isEmpty) {
      return Scaffold(
        backgroundColor: mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('CalendarShare'),
          ),
          body: SingleChildScrollView(
              child: Column(children: [
            const SizedBox(height: 30),
            const Text('ユーザーをさがす', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            Row(children: [
              SizedBox(width: size.width * 0.05),
              Container(
                width: size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                  color: Colors.white,
                ),
                child: TextFieldInput(
                  hintText: 'ユーザー名またはメールアドレス',
                  textInputType: TextInputType.text,
                  textEditingController: _searchuserController,
                ),
              ),
              SizedBox(width: size.width * 0.05),
              SizedBox(
                width: size.width * 0.25,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      searchUserList = [];
                      searchUserData = [];
                    });
                    searchUser();
                  },
                  child: const Text('検索'),
                ),
              ),
              SizedBox(width: size.width * 0.05)
            ]),
            const SizedBox(height: 30),

            searchUserData.isEmpty
                ? Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        child: Center(
                          child: Text(
                            'ユーザーが見つかりませんでした',
                            style:
                                TextStyle(fontSize: size.width * 0.05),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )

                //検索結果の表示
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchUserData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        child: Row(
                          children: [
                            //アイコン画像
                            const SizedBox(width: 10),
                            SizedBox(
                              width: size.width * 0.1,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  searchUserData[index]['photoUrl'],
                                ),
                              ),
                            ),

                            SizedBox(width: size.width * 0.05),

                            SizedBox(
                              width: size.width * 0.3,
                              child: Text(
                                searchUserData[index]['username'],
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if (followingList
                                .contains(searchUserData[index]['uid']))
                              SizedBox(
                                width: size.width * 0.4,
                                height: size.height * 0.05,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                        255, 135, 184, 224),
                                  ),
                                  child: const Center(
                                    child: Text('フォロー中',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              )
                            else if (searchUserData[index]['uid'] ==
                                currentUserID)
                              SizedBox(
                                  width: size.width * 0.4,
                                  height: size.height * 0.05,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 135, 184, 224),
                                      ),
                                      child: const Center(
                                        child: Text('自分です',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      )))
                            else
                              SizedBox(
                                width: size.width * 0.4,
                                child: ElevatedButton(
                                  onPressed: () {
                                    addfollowing(searchUserData[index]['uid']);
                                    setState(() {
                                      followingListData = [];
                                      //calendarListData = [];
                                      showfollower();
                                      //showcalendar();
                                    });
                                  },
                                  child: const Text('フォローする'),
                                ),
                              ),

                            SizedBox(width: size.width * 0.05)
                          ],
                        ),
                      );
                    },
                  ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 30),
            const Text(
              'フォロー中のユーザー',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),

            */

    return isLoading
        ? Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()))
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Padding(
                padding: EdgeInsets.only(
                    top: size.height * 0.01, bottom: size.height * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: size.width * 0.05),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(userData['photoUrl']),
                    ),
                    SizedBox(width: size.width * 0.05),
                    Text(
                      userData['username'],
                      style: TextStyle(fontSize: size.height * 0.03),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Container(
                            height: size.height * 0.45,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                SizedBox(
                                  height: size.height * 0.22,
                                  width: size.height * 0.22,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        NetworkImage(userData['photoUrl']),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                SizedBox(
                                    height: size.height * 0.04,
                                    child: Text(
                                      userData['username'],
                                      style: TextStyle(
                                          fontSize: size.height * 0.03),
                                    )),
                                SizedBox(
                                  height: size.height * 0.04,
                                ),

                                //
                                SizedBox(
                                  height: size.height * 0.07,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                  ),
                                ),
                                //
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    child: Padding(
                      padding: EdgeInsets.all(size.height * 0.02),
                      child: Text(
                        'どのフォロワーさんにカレンダーを共有しますか？',
                        style: TextStyle(fontSize: size.height * 0.02),
                      ),
                    ),
                  ),
                  followingListData.isEmpty
                      ? SizedBox(
                          width: size.width * 0.9,
                          child: Center(
                            child: Text(
                              'フォロー中のユーザーがいません',
                              style: TextStyle(fontSize: size.width * 0.05),
                            ),
                          ),
                        )
                      //followingの結果表示
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: followingList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: size.height * 0.01,
                                  bottom: size.height * 0.01),
                              child: Container(
                                child: Row(
                                  children: [
                                    //アイコン画像
                                    SizedBox(width: size.width * 0.05),
                                    SizedBox(
                                        width: size.width * 0.1,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                              followingListData[index]
                                                  ['photoUrl'],
                                            ))),

                                    SizedBox(width: size.width * 0.05),

                                    SizedBox(
                                        width: size.width * 0.2,
                                        child: Text(
                                            followingListData[index]
                                                ['username'],
                                            style: TextStyle(
                                              fontSize: size.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                            ))),

                                    SizedBox(
                                      width: size.width * 0.5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectname =
                                                followingListData[index]
                                                    ['username'];
                                            selectuid =
                                                followingListData[index]['uid'];
                                          }); //ここから誰にカレンダーを共有ずみであるのかを表示させる

                                          showDialog(
                                            context: context,
                                            builder: ((context) {
                                              //Userを決定//ここでこのUserのwatchingcalendarを取得
                                              useruid = followingListData[index]
                                                  ['uid'];

                                              return AlertDialog(
                                                title: Text(
                                                    'どのカレンダーを\n「$selectnameさん」に共有しますか？'),
                                                content: SingleChildScrollView(
                                                  child:
                                                      calendarListData.isEmpty
                                                          ? const Center(
                                                              child: Text(
                                                              '共有できるカレンダーがありません',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red),
                                                            ))
                                                          : Column(
                                                              children:
                                                                  List.generate(
                                                                calendarListData
                                                                    .length,
                                                                (i) {
                                                                  return FutureBuilder(
                                                                      future: FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .doc(
                                                                              useruid)
                                                                          .collection(
                                                                              'calendarwatching')
                                                                          .get(),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot.connectionState ==
                                                                            ConnectionState
                                                                                .waiting) {
                                                                          return const Center(
                                                                              child: CircularProgressIndicator());
                                                                        } else if (snapshot
                                                                            .hasError) {
                                                                          print(
                                                                              snapshot.error);
                                                                          return const Center(
                                                                              child: CircularProgressIndicator());
                                                                        } else {
                                                                          //sanpshotのdataにcalendaridが含まれているかどうか

                                                                          List<String>
                                                                              snapshotlist =
                                                                              [];
                                                                          for (int i = 0;
                                                                              i < snapshot.data!.docs.length;
                                                                              i++) {
                                                                            snapshotlist.add(snapshot.data!.docs[i].data()['calendarid']);
                                                                          }
                                                                          print(
                                                                              'リスト$snapshotlist');
                                                                          print(
                                                                              'カレンダーリストデータ$calendarListData');

                                                                          calendarid =
                                                                              calendarListData[i]['calendarid'];

                                                                          return (snapshotlist.contains(calendarid))
                                                                              ? Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Padding(padding: const EdgeInsets.all(8.0), child: Text(calendarListData[i]['chilename'], style: TextStyle(color: primaryColor, fontSize: size.height * 0.03))),
                                                                                    //calendar watchingUserUidにuseruidが含まれているかどうか

                                                                                    Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: ElevatedButton(
                                                                                            onPressed: () {
                                                                                              unsharecalendar(calendarListData[i]['calendarid'], useruid);
                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  builder: ((context) {
                                                                                                    return AlertDialog(title: const Text('削除できました！'), actions: [
                                                                                                      ElevatedButton(
                                                                                                          child: const Text('戻る'),
                                                                                                          onPressed: () {
                                                                                                            //戻る
                                                                                                            Navigator.of(context).pop();
                                                                                                            Navigator.of(context).pop();

                                                                                                            // calendarListData.clear();
                                                                                                            //showcalendar();
                                                                                                          })
                                                                                                    ]);
                                                                                                  }));
                                                                                            },
                                                                                            child: Container(
                                                                                              child: const Text(
                                                                                                '削除？',
                                                                                                style: TextStyle(color: Colors.red),
                                                                                              ),
                                                                                            )))
                                                                                  ],
                                                                                )
                                                                              : Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Padding(padding: const EdgeInsets.all(8.0), child: Text(calendarListData[i]['chilename'], style: TextStyle(color: primaryColor, fontSize: size.height * 0.03))),
                                                                                    //calendar watchingUserUidにuseruidが含まれているかどうか

                                                                                    Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: ElevatedButton(
                                                                                            onPressed: () {
                                                                                              sharecalendar(
                                                                                                calendarListData[i]['calendarid'],
                                                                                                useruid,
                                                                                              );

                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  builder: ((context) {
                                                                                                    return AlertDialog(title: const Text('共有できました！'), actions: [
                                                                                                      ElevatedButton(
                                                                                                          child: const Text('戻る'),
                                                                                                          onPressed: () {
                                                                                                            //戻る
                                                                                                            Navigator.of(context).pop();
                                                                                                            Navigator.of(context).pop();

                                                                                                            // calendarListData.clear();
                                                                                                            //showcalendar();
                                                                                                          })
                                                                                                    ]);
                                                                                                  }));
                                                                                            },
                                                                                            child: const Text('共有する')))
                                                                                  ],
                                                                                );
                                                                        }
                                                                      });
                                                                  /*
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                        padding:
                                                                            const EdgeInsets
                                                                                .all(
                                                                                8.0),
                                                                        child: Text(
                                                                            calendarListData[i]
                                                                                [
                                                                                'chilename'],
                                                                            style: TextStyle(
                                                                                color:
                                                                                    primaryColor,
                                                                                fontSize:
                                                                                    size.height * 0.03))),
                                                                    //calendar watchingUserUidにuseruidが含まれているかどうか
                            
                                                                    if (res ==
                                                                        'true')
                                                                      Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child: ElevatedButton(
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  calendarid = calendarListData[i]['calendarid'];
                                                                                  useruid = followingListData[i]['uid'];
                                                                                });
                            
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: ((context) {
                                                                                      return AlertDialog(title: const Text('共有済み'), actions: [
                                                                                        ElevatedButton(
                                                                                            child: const Text('戻る'),
                                                                                            onPressed: () {
                                                                                              //戻る
                            
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.of(context).pop();
                                                                                            })
                                                                                      ]);
                                                                                    }));
                                                                              },
                                                                              child: const Text(
                                                                                '共有済み',
                                                                                style:
                                                                                    TextStyle(color: primaryColor),
                                                                              )))
                                                                    else if (res ==
                                                                        'false')
                                                                      Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child: ElevatedButton(
                                                                              onPressed: () {
                                                                                // setState(
                                                                                //     () {
                                                                                //   calendarid =
                                                                                //       calendarListData[index]['calendarid'];
                                                                                //   useruid =
                                                                                //       followingListData[index]['uid'];
                                                                                // });
                                                                                print('確認！！！！$calendarid:$useruid');
                            
                                                                                sharecalendar(
                                                                                  calendarid,
                                                                                  useruid,
                                                                                );
                            
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: ((context) {
                                                                                      return AlertDialog(title: const Text('共有できました！'), actions: [
                                                                                        ElevatedButton(
                                                                                            child: const Text('戻る'),
                                                                                            onPressed: () {
                                                                                              //戻る
                                                                                              Navigator.of(context).pop();
                                                                                              Navigator.of(context).pop();
                                                                                              //calendarListData.isEmpty || followingListData.isEmpty
                                                                                              calendarListData.clear();
                                                                                              showcalendar();
                                                                                            })
                                                                                      ]);
                                                                                    }));
                                                                              },
                                                                              child: const Text('共有する')))
                                                                    else
                                                                      const CircularProgressIndicator()
                                                                  ],
                                                                );
                                                                */
                                                                },
                                                              ),
                                                            ),
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    child: const Text('キャンセル'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            }),
                                          );
                                        },
                                        child: const Text('カレンダーを共有'),
                                      ),
                                    ),

                                    SizedBox(width: size.width * 0.05)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 30),
                  const Text('ユーザーをさがす', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 30),
                  Row(children: [
                    SizedBox(width: size.width * 0.05),
                    Container(
                      width: size.width * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // 角丸の程度を指定
                        color: Colors.white,
                      ),
                      child: TextFieldInput(
                        hintText: 'ユーザー名またはメールアドレス',
                        textInputType: TextInputType.text,
                        textEditingController: _searchuserController,
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    SizedBox(
                      width: size.width * 0.25,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            searchUserList = [];
                            searchUserData = [];
                          });
                          userData['blocked'] == []
                              ? searchUser()
                              : searchUser(userData['blocked']);
                        },
                        child: const Text('検索'),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05)
                  ]),
                  const SizedBox(height: 30),
                  searchUserData.isEmpty
                      ? SizedBox(
                          width: size.width * 0.9,
                          child: Center(
                            child: Text(
                              'ユーザーが見つかりませんでした',
                              style: TextStyle(fontSize: size.width * 0.05),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchUserData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              child: Padding(
                                padding: EdgeInsets.all(size.height * 0.01),
                                child: Row(
                                  children: [
                                    //アイコン画像
                                    SizedBox(width: size.width * 0.05),
                                    SizedBox(
                                      width: size.width * 0.1,
                                      child: CircleAvatar(
                                        radius: size.width * 0.1,
                                        backgroundImage: NetworkImage(
                                          searchUserData[index]['photoUrl'],
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: size.width * 0.05),

                                    SizedBox(
                                      width: size.width * 0.3,
                                      child: Text(
                                        searchUserData[index]['username'],
                                        style: TextStyle(
                                          fontSize: size.width * 0.08,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    if (followingList
                                        .contains(searchUserData[index]['uid']))
                                      SizedBox(
                                        width: size.width * 0.4,
                                        height: size.height * 0.05,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: const Color.fromARGB(
                                                255, 135, 184, 224),
                                          ),
                                          child: const Center(
                                            child: Text('フォロー中',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ),
                                      )
                                    else if (searchUserData[index]['uid'] ==
                                        currentUserID)
                                      SizedBox(
                                          width: size.width * 0.4,
                                          height: size.height * 0.05,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color.fromARGB(
                                                    255, 135, 184, 224),
                                              ),
                                              child: const Center(
                                                child: Text('自分です',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              )))
                                    else
                                      SizedBox(
                                        width: size.width * 0.4,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            addfollowing(
                                                searchUserData[index]['uid']);
                                            setState(() {
                                              followingListData = [];
                                              showfollower();
                                            });
                                          },
                                          child: const Text('フォローする'),
                                        ),
                                      ),

                                    SizedBox(width: size.width * 0.05)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          );
  }
}
