import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarEditWidget extends StatefulWidget {
  final List calendarData;

  const CalendarEditWidget({
    super.key,
    required this.calendarData,
  });

  @override
  State<CalendarEditWidget> createState() => _CalendarEditWidgetState();
}

class _CalendarEditWidgetState extends State<CalendarEditWidget> {
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  List<String> followingList = [];
  List followingListData = [];
  List watchingUserUidList = [];
  List watchingUserDataList = [];
  List calendarInf = [];
//String calendarid
  showwatchingUser(String calendarid) async {
    var watchingUserUidListDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID.toString())
        .collection('following')
        .get();
    //print('現在のユーザー名：$currentUserID');

    if (watchingUserUidListDocument.docs.length > 0) {
      for (int i = 0; i < watchingUserUidListDocument.docs.length; i++) {
        watchingUserUidList
            .add(watchingUserUidListDocument.docs[i].data()['uid']);
      }
      //print('フォロワー：$followingList');
    } else {
      //print('フォロワーがいません');
    }

    setState(() {
      watchingUserUidList;
    });

    var allUsersDocument =
        await FirebaseFirestore.instance.collection('users').get();

    for (int i = 0; i < allUsersDocument.docs.length; i++) {
      for (int k = 0; k < watchingUserUidList.length; k++) {
        if (((allUsersDocument.docs[i].data() as dynamic)['uid']) ==
            watchingUserUidList[k]) {
          watchingUserDataList.add(allUsersDocument.docs[i].data());
        }
      }
    }
    print('できたで！');

    setState(() {
      watchingUserDataList;
    });
    // return watchingUserDataList;
  }

/*
  getcalendarInf() async {
    var calendarget = await FirebaseFirestore.instance
        .collection('calendar')
        .doc(widget.calendarid)
        .get();
    print(calendarget.data());
    calendarInf.add(calendarget.data());
  }
*/
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //showwatchingUser(widget.calendarData[0]['calendarid']);
    //showwatchingUser(widget.calendarData.['calendarid']); //watchingUserDataListができた
    //getcalendarInf(); //calendarInfができた
  }

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    print(calendarInf);
    //showwatchingUser(widget.calendarData[0]['calendarid']);

    //print('watchingUserDataListは$watchingUserDataList');
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            SizedBox(height: _screenSize.height * 0.01),
            Text(
              'カレンダーの情報',
              style: TextStyle(fontSize: _screenSize.height * 0.03),
            ),
            SizedBox(height: _screenSize.height * 0.05),
            Text(
              '閲覧者',
              style: TextStyle(fontSize: _screenSize.height * 0.03),
            ),
            /*
            Column(
              children: List.generate(watchingUserDataList.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: _screenSize.height * 0.1,
                    width: _screenSize.width * 0.9,
                    child: Row(children: [
                      //photo
                      Container(
                        width: _screenSize.width * 0.1,
                        height: _screenSize.width * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(watchingUserDataList[index]
                                    ['photoUrl']
                                .toString()),
                          ),
                        ),
                      ),

                      SizedBox(width: _screenSize.width * 0.05),

                      Container(
                        width: _screenSize.width * 0.5,
                        child: Text(
                          watchingUserDataList[index]['username'],
                          style: TextStyle(fontSize: _screenSize.height * 0.03),
                        ),
                      ),
                      ElevatedButton(onPressed: () {}, child: const Text('編集'))
                    ]),
                  ),
                );
              }),
            ),
          */
          ],
        ));
  }
}
