import 'package:flutter/material.dart';
import 'package:hazimetecalendar/pages/custom_stamp_page.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool testcheck = true; //データの取得を確認
  bool testtestcheck = true; //データの取得を確認
  //bool _isVisible = false; // 表示/非表示を切り替えるフラグ
  bool iscustom = false; //カスタムの表示

  //Userのデータ取得
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  final CalendarController _controller = CalendarController();
  final CalendarController _watchingcontroller = CalendarController();

  late CalendarDataSource _dataSource;
  late CalendarDataSource _watchingdataSource;

  bool isVisible = false;
  bool detailisVisible = false;
  CalendarTapDetails? selectedDayDetails;
  CalendarLongPressDetails? selectedDayLongPressDetails;
  String? note;

  bool isLikeSentClicked = true;
  bool _loading = false; //スタンプ情報を入手するまでのbool

  int calendarpage = 0; //表示するカレンダーの情報
  int watchingcalendarpage = 0; //閲覧するカレンダー

  List stampDataList = [];
  List watchingstampDataList = [];

  List<Appointment> appointments = <Appointment>[];
  List<Appointment> watchingappointments = <Appointment>[];

  List<String> calendarList = [];
  List calendarListData = [];
  //他人のカレンダーを閲覧
  List<String> watchingcalendarList = [];
  List watchingcalendarListData = [];

  Future<void> getStampInfo(String calendar_name) async {
    stampDataList = [];
    appointments = [];
    var stamplistdocument = await FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendar_name)
        .collection('stamp_list')
        .get();

    for (int i = 0; i < stamplistdocument.docs.length; i++) {
      stampDataList.add(stamplistdocument.docs[i].data());
    }
    //ここでデータをとれてる
    //print('likeSentList: $likeSentList');
    //print('stampDataList: $stampDataList');

    for (int i = 0; i < stampDataList.length; i++) {
      appointments.add(
        Appointment(
            startTime: stampDataList[i]['startTime'].toDate(),
            endTime: stampDataList[i]['endTime'].toDate(),
            subject: 'Meeting',
            notes: stampDataList[i]['notes'].toString()),
      );
    }

    //print('appointments: $appointments');

    setState(() {
      stampDataList;
      appointments;
      _dataSource = _DataSource(appointments);
    });
  }

  Future<void> getwatchingStampInfo(String calendar_name) async {
    watchingstampDataList = [];
    watchingappointments = [];
    var stamplistdocument = await FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendar_name)
        .collection('stamp_list')
        .get();

    for (int i = 0; i < stamplistdocument.docs.length; i++) {
      watchingstampDataList.add(stamplistdocument.docs[i].data());
    }
    //ここでデータをとれてる
    //print('likeSentList: $likeSentList');
    //print('stampDataList: $stampDataList');

    for (int i = 0; i < watchingstampDataList.length; i++) {
      watchingappointments.add(
        Appointment(
            startTime: watchingstampDataList[i]['startTime'].toDate(),
            endTime: watchingstampDataList[i]['endTime'].toDate(),
            subject: 'Meeting',
            notes: watchingstampDataList[i]['notes'].toString()),
      );
    }

    //print('appointments: $appointments');

    setState(() {
      watchingstampDataList;
      watchingappointments;
      _watchingdataSource = _DataSource(watchingappointments);
    });
  }

  void addStamp(CalendarTapDetails selectedDayDetails, String note,
      String calendar_name) async {
    Appointment app = Appointment(
        startTime: selectedDayDetails.date!,
        endTime: selectedDayDetails.date!,
        subject: 'テスト中',
        notes: note);
    await FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendar_name)
        .collection('stamp_list')
        .doc('${app.startTime}')
        .set({
      'startTime': app.startTime,
      'endTime': app.endTime,
      'subject': app.subject,
      'notes': app.notes,
    });
    setState(() {
      stampDataList.add(app);
      appointments.add(app);
      _dataSource.appointments!.add(app);
      _dataSource
          .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
    });
  }

  void deleteStamp(CalendarLongPressDetails calendarLongPressDetails) {
    print('削除スタート');

    //startTimeが同じもののAppointmentを見つける
    //print(appointments[0].startTime);
    //print('LongPressデータ${calendarLongPressDetails.date}');

    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].startTime == calendarLongPressDetails.date) {
        print('削除するよ');
        //print(appointments[i].startTime);
        //print(calendarLongPressDetails.date);
        FirebaseFirestore.instance
            .collection('calendars')
            .doc(calendarListData[calendarpage]['calendarid'])
            .collection('stamp_list')
            .doc('${appointments[i].startTime}')
            .delete();
        setState(() {
          appointments.remove(
              appointments[i].startTime == calendarLongPressDetails.date);
          appointments.remove(
              appointments[i].startTime == calendarLongPressDetails.date);
          _dataSource.appointments!.remove(
              appointments[i].startTime == calendarLongPressDetails.date);
          _dataSource.notifyListeners(
              CalendarDataSourceAction.remove, <Appointment>[appointments[i]]);
        });
      } else {
        print('削除できないよ');
      }
    }
  }

  void chagestampisVisibleview() {
    isVisible = !isVisible;
  }

  void chagedetailisVisibleview() {
    detailisVisible = !detailisVisible;
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    print('タップされたよ');
    setState(() {
      chagestampisVisibleview();
      detailisVisible = true;
    });
    setState(() {
      selectedDayDetails = calendarTapDetails;
    });
  }

  void claednarLongPressed(CalendarLongPressDetails calendarLongPressDetails) {
    print('長押しされたよ');
    note = '';
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].startTime == calendarLongPressDetails.date) {
        note = appointments[i].notes;
      }
    }

    (note != '')
        ? showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Image.asset(note!), // スタンプ画像を表示
                content: calendarLongPressDetails.date.toString().isNotEmpty
                    ? Text(
                        '${calendarLongPressDetails.date.toString().substring(0, 4)}年${calendarLongPressDetails.date.toString().substring(5, 7)}月${calendarLongPressDetails.date.toString().substring(8, 10)}日の、このスタンプを削除しますか？',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      )
                    : const Text('日付を選択してください'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('削除'),
                    onPressed: () {
                      deleteStamp(calendarLongPressDetails);
                      Navigator.of(context).pop();

                      note = '';
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
          )
        : showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('スタンプがありません'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('戻る'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
  }

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

//他人のカレンダーを閲覧
  watchingcalendar() async {
    if (mounted) {
      var followingListDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID.toString())
          .collection('calendarwatching')
          .get();

      if (followingListDocument.docs.isNotEmpty) {
        for (int i = 0; i < followingListDocument.docs.length; i++) {
          watchingcalendarList
              .add(followingListDocument.docs[i].data()['calendarid']);
        }
        //print('calendarList：$calendarList');
      } else {
        print('フォロワーがいません');
      }

      setState(() {
        watchingcalendarList;
      });
      watchingcalendarKeysDataFromUserCollection(watchingcalendarList);
    } else {
      print('処理は実行されませんでした');
    }
  }

  watchingcalendarKeysDataFromUserCollection(List<String> keysList) async {
    var calendarDocument =
        await FirebaseFirestore.instance.collection('calendars').get();

    for (int i = 0; i < calendarDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((calendarDocument.docs[i].data() as dynamic)['calendarid']) ==
            keysList[k]) {
          watchingcalendarListData.add(calendarDocument.docs[i].data());
        }
      }
    }

    setState(() {
      watchingcalendarListData;
    });
  }

//初期のカレンダーセット
  getFirstStamp() {
    if (calendarListData.isNotEmpty) {
      getStampInfo(calendarListData[0]['calendarid']);
    }
    if (watchingcalendarListData.isNotEmpty) {
      getwatchingStampInfo(watchingcalendarListData[0]['calendarid']);
    }
  }

/*
  @override
  void dispose() {
    _controller.dispose();
    stampDataList.clear();
    watchingstampDataList.clear();
    super.dispose();
  }
*/

  @override
  void initState() {
    super.initState();
    showcalendar();
    watchingcalendar();
    getFirstStamp();
  }

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    //double _scale = 1.0; // 初期のスケール値

    List<String> stampPaths = [
      'assets/images/stamps/stamp_001_kabocha.png',
      'assets/images/stamps/stamp_002_firststanding.png',
      'assets/images/stamps/stamp_003_ichig.png',
      'assets/images/stamps/stamp_004_iyaiya.png',
      'assets/images/stamps/stamp_005_omiyamairi.png',
      'assets/images/stamps/stamp_006_jagaimo.png',
      'assets/images/stamps/stamp_007_tomato.png',
      'assets/images/stamps/stamp_008_ninjin.png',
      'assets/images/stamps/stamp_009_harfborthday.png',
      'assets/images/stamps/stamp_010_papa.png',
      'assets/images/stamps/stamp_011_burokkori.png',
      'assets/images/stamps/stamp_012_horenso.png',
      'assets/images/stamps/stamp_013_mama.png',
      'assets/images/stamps/stamp_014_wakuchinfinished.png',
      'assets/images/stamps/stamp_015_ikkagetukenshin.png',
      'assets/images/stamps/stamp_016_car.png',
      'assets/images/stamps/stamp_017_syuku100nichi.png',
      'assets/images/stamps/stamp_018_suizokukann.png',
      'assets/images/stamps/stamp_019_densya.png',
      'assets/images/stamps/stamp_020_zoonew.png',
      'assets/images/stamps/stamp_021_yomikikase.png',
      'assets/images/stamps/stamp_022_aruita.png',
      'assets/images/stamps/stamp_023_tatta.png',
      'assets/images/stamps/stamp_024_kamikitta.png',
      'assets/images/stamps/stamp_025_tobira.png',
    ];

// スタンプを生成するウィジェット
    List<Widget> stampWidgets = List.generate(stampPaths.length, (index) {
      return MaterialButton(
        onPressed: () {
          setState(() {
            note = stampPaths[index];
          });
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Image.asset(note!), // スタンプ画像を表示
                content: selectedDayDetails!.date.toString().isNotEmpty
                    ? Text(
                        '${selectedDayDetails!.date.toString().substring(0, 4)}年${selectedDayDetails!.date.toString().substring(5, 7)}月${selectedDayDetails!.date.toString().substring(8, 10)}日にこのスタンプを押しますか？',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      )
                    : const Text('日付を選択してください'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('押す！'),
                    onPressed: () {
                      addStamp(selectedDayDetails!, note!,
                          calendarListData[calendarpage]['calendarid']);
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
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(stampPaths[index]), // スタンプ画像を表示
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    });

// スタンプを表示するコンテナ
    Widget stampContainer = GridView.count(
      crossAxisCount: 5, // 5列に設定（調整が必要かもしれません）
      children: stampWidgets,
    );

    try {
      //はじめのページだけは今取得する
      //何度もデータが呼び起こされるため、testcheckで無理やり停止した。
      //初期のカレンダーセット
      if (calendarListData.isNotEmpty & testcheck == true) {
        getStampInfo(calendarListData[0]['calendarid']);
        //print('ゲットだぜーー');
        testcheck = false;
      }
      if (watchingcalendarListData.isNotEmpty & testtestcheck == true) {
        getwatchingStampInfo(watchingcalendarListData[0]['calendarid']);
        //print('ウェイウェイ');
        testtestcheck = false;
      }

      print('実行');
      //print(appointments);
      //print(stampDataList);

      if ((calendarListData.length + watchingcalendarListData.length) == 0) {
        return const Center(
          child: Text('カレンダーを作成しましょう\n設定のページから作成できます'),
        );
      } else {
        /*
        return StreamBuilder(
            stream: getFirstStamp(),
            builder: (context, snapshot) {
              return Container();
            });
        */

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ja')],
          locale: const Locale('ja'),
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: mobileBackgroundColor,
/*
              floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    iscustom
                        ? TextButton(
                            onPressed: () {
                              Get.to(() => const CustomStampPage());
                            },
                            child: const Text('スタンプをカスタム'))
                        : const Text(''),
                    FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 240, 185, 203),
                      onPressed: () {
                        setState(() {
                          iscustom = !iscustom;
                          isVisible = true;
                        });
                      },
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  ]),
              */
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
                toolbarHeight: _screenSize.height * 0.03,
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'はじめてカレンダー',
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: _screenSize.height * 0.02),
                  ),
                ),
                automaticallyImplyLeading: false,
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(icon: Icon(Icons.cloud_outlined)),
                    Tab(icon: Icon(Icons.beach_access_sharp)),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  //自分のカレンダーを閲覧
                  calendarListData.isEmpty
                      ? const Center(
                          child: Text('カレンダーを追加してください'),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              //上の名前の一覧表示
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                      calendarListData.length, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            stampDataList.clear();
                                            getStampInfo(calendarListData[index]
                                                ['calendarid']);
                                            calendarpage = index;
                                          });
                                        } else {
                                          print('処理失敗');
                                        }
                                      },
                                      child: GestureDetector(
                                        onLongPress: () {
                                          print('長押しされたよ');
                                          //
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    '「${calendarListData[index]['chilename']}」さんのカレンダーを削除しますか？'),
                                                content:
                                                    const Text('※削除すると復元できません'),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    child: const Text('削除'),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                              '本当に削除しますか？',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            content: const Text(
                                                                '※削除すると復元できません'),
                                                            actions: [
                                                              ElevatedButton(
                                                                child:
                                                                    const Text(
                                                                        '削除'),
                                                                onPressed: () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'calendars')
                                                                      .doc(calendarListData[
                                                                              index]
                                                                          [
                                                                          'calendarid'])
                                                                      .delete();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              ElevatedButton(
                                                                child:
                                                                    const Text(
                                                                        'キャンセル'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text('キャンセル'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          //
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 200, 215, 228),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            height: _screenSize.height * 0.05,
                                            width: _screenSize.width * 0.4,
                                            child: Center(
                                              child: Text(
                                                calendarListData[index]
                                                    ['chilename'],
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize:
                                                        _screenSize.height *
                                                            0.03),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                              const SizedBox(height: 10),

                              //表示カレンダーの名前表示
                              Text(
                                calendarListData[calendarpage]['chilename'],
                                style: const TextStyle(
                                    color: lettercolor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              //カレンダー本体
                              Container(
                                height: 630,
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]),

                                //カレンダー本体
                                child: SfCalendar(
                                  view: CalendarView.month,
                                  //showDatePickerButton: true, //月を選べるボタン
                                  onTap: calendarTapped,
                                  onLongPress: claednarLongPressed,

                                  controller: _controller,
                                  dataSource: _dataSource, //ここが重要
                                  appointmentTimeTextFormat: 'HH:mm',

                                  monthViewSettings: const MonthViewSettings(
                                    dayFormat: 'EEE',
                                    numberOfWeeksInView: 4, //何週を表示するのか指定
                                    appointmentDisplayCount: 1, //セルの大きさを指定
                                    appointmentDisplayMode:
                                        MonthAppointmentDisplayMode
                                            .appointment, //ここが重要
                                    showAgenda: false, //下の予定表一覧
                                    navigationDirection:
                                        MonthNavigationDirection.horizontal,
                                    monthCellStyle: MonthCellStyle(
                                      textStyle: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ), //日付の文字の色
                                      trailingDatesTextStyle: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontSize: 15,
                                          color: Colors.red),
                                      leadingDatesTextStyle: TextStyle(
                                          fontStyle: FontStyle.normal,
                                          fontSize: 15,
                                          color: Colors.blue),
                                    ),
                                  ),

                                  appointmentBuilder: (BuildContext context,
                                      CalendarAppointmentDetails details) {
                                    final Appointment meeting =
                                        details.appointments.first;

                                    return Container(

                                        //metting.notesにhttpが含まれているか判断する

                                        child: (meeting.notes!.contains('http'))
                                            ?
                                            //ここで画像を表示させる
                                            Image(
                                                image: NetworkImage(
                                                    '${meeting.notes}'),
                                                fit: BoxFit.fill,
                                              )
                                            : Image(
                                                image: ExactAssetImage(
                                                    '${meeting.notes}'),
                                                fit: BoxFit.fill,
                                              ));
                                    /*
                                    return Container(
                                      child: Text(meeting.subject),
                                    );
                                    */
                                  },
                                ),
                              ),
                              //スタンプ格納されてる
                              Visibility(
                                visible: isVisible,
                                child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    margin:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ]),
                                    child: stampContainer),
                              ),
                              //1日の記録が格納されている
                              /*
                                Visibility(
                                  visible: detailisVisible,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ]),
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: [
                                        const SizedBox(height: 40),
                                      ],
                                    )),
                                  ),
                                ),
                                */

                              //selectedDayDetails!.date?.//startTime: 2023-10-25 00:00:00.000, endTime: 2023-10-25 00:00:00.000,
                            ],
                          ),
                        ),

                  //他人のカレンダーを閲覧
                  watchingcalendarListData.isEmpty
                      ? const Center(
                          child: Text('カレンダーを追加してください'),
                        )
                      : SingleChildScrollView(
                          child: Column(children: [
                            //上の名前の一覧表示
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                    watchingcalendarListData.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          _loading = true;
                                          watchingstampDataList.clear();

                                          getwatchingStampInfo(
                                              watchingcalendarListData[index]
                                                  ['calendarid']);

                                          watchingcalendarpage = index;
                                          _loading = false;
                                          //print('処理終了');
                                        });
                                      }
                                    },
                                    onLongPress: () {
                                      //
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  '「${watchingcalendarListData[index]['chilename']}」さんのカレンダーを削除しますか？'),
                                              content:
                                                  const Text('※削除すると復元できません'),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  child: const Text('削除'),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            '本当に削除しますか？',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                          content: const Text(
                                                              '※削除すると復元できません'),
                                                          actions: [
                                                            ElevatedButton(
                                                              child: const Text(
                                                                  '削除'),
                                                              onPressed: () {
                                                                //FirebaseFirestore
                                                                //    .instance
                                                                //     .collection(
                                                                //          'calendars')
                                                                //     .doc(calendarListData[
                                                                //           index]
                                                                //          [
                                                                //         'calendarid'])
                                                                //       .delete();

                                                                var deleteWatchingCalendar = FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(
                                                                        currentUserID)
                                                                    .collection(
                                                                        'calendarwatching')
                                                                    .where(
                                                                        'calendarid',
                                                                        isEqualTo:
                                                                            '${watchingcalendarListData[index]['calendarid']}')
                                                                    .get();

                                                                FirebaseFirestore
                                                                    .instance
                                                                    .runTransaction(
                                                                        (Transaction
                                                                            myTransaction) async {
                                                                  for (DocumentSnapshot document
                                                                      in (await deleteWatchingCalendar)
                                                                          .docs) {
                                                                    await myTransaction
                                                                        .delete(
                                                                            document.reference);
                                                                  }
                                                                });

                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            ElevatedButton(
                                                              child: const Text(
                                                                  'キャンセル'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('キャンセル'))
                                              ],
                                            );
                                          });
                                      //
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 200, 215, 228),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        height: _screenSize.height * 0.05,
                                        width: _screenSize.width * 0.4,
                                        child: Center(
                                          child: Text(
                                            watchingcalendarListData[index]
                                                ['chilename'],
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize:
                                                    _screenSize.height * 0.03),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              watchingcalendarListData[watchingcalendarpage]
                                  ['chilename'],
                              style: const TextStyle(
                                  color: lettercolor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            //カレンダー本体
                            Container(
                              height: 600,
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]),

                              //カレンダー本体
                              child: SfCalendar(
                                view: CalendarView.month,
                                //showDatePickerButton: true, //月を選べるボタン
                                onTap: calendarTapped,
                                controller: _watchingcontroller,
                                dataSource: _watchingdataSource, //ここが重要
                                appointmentTimeTextFormat: 'HH:mm',
                                monthViewSettings: const MonthViewSettings(
                                  dayFormat: 'EEE',
                                  numberOfWeeksInView: 4, //何週を表示するのか指定
                                  appointmentDisplayCount: 1, //セルの大きさを指定
                                  appointmentDisplayMode:
                                      MonthAppointmentDisplayMode
                                          .appointment, //ここが重要
                                  showAgenda: false, //下の予定表一覧
                                  navigationDirection:
                                      MonthNavigationDirection.horizontal,
                                  monthCellStyle: MonthCellStyle(
                                    textStyle: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ), //日付の文字の色
                                    trailingDatesTextStyle: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15,
                                        color: Colors.red),
                                    leadingDatesTextStyle: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15,
                                        color: Colors.blue),
                                  ),
                                ),
                                appointmentBuilder: (BuildContext context,
                                    CalendarAppointmentDetails details) {
                                  final Appointment meeting =
                                      details.appointments.first;
                                  if (_controller.view !=
                                      CalendarView.schedule) {
                                    return Container(
                                      child:
                                          //ここで画像を表示させる
                                          Container(
                                        child: Image(
                                          image: ExactAssetImage(
                                              '${meeting.notes}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    child: Text(meeting.subject),
                                  );
                                },
                              ),
                            ),
                          ]),
                        ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('エラー$e');
      return const Scaffold(
        backgroundColor: mobileBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    stampDataList.clear();
    watchingstampDataList.clear();
    super.dispose();
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
