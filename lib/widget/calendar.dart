import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class Calendar extends StatefulWidget {
  final stampList;

  const Calendar({super.key, required this.stampList});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CalendarController _controller = CalendarController();
  late CalendarDataSource _dataSource;
  bool isVisible = false;
  bool detailisVisible = false;
  CalendarTapDetails? selectedDayDetails;
  //DateTime birthday = DateTime(2023, 1, 1, 1, 1);
  // _DataSource _getDataSource() {
  //   List<Appointment> appointments = <Appointment>[];
  //   //print(StampList().toString());

  //   appointments.add(
  //     Appointment(
  //         startTime: DateTime(2023, 10, 31, 10, 30),
  //         endTime: DateTime(2023, 10, 31, 10, 30).add(const Duration(hours: 1)),
  //         subject: 'Meeting',
  //         notes: 'assets/images/stamps/stamp_002_firststanding.png'),
  //   );

  //   /*

  //   for (int i = 0; i < widget.snap.length; i++) {
  //     appointments.add(
  //       Appointment(
  //           startTime: widget.snap[i]['startTime'].toDate(),
  //           endTime: widget.snap[i]['endTime'].toDate(),
  //           subject: 'Meeting',
  //           notes: widget.snap[i]['notes'].toString()),
  //     );
  //   }
  //   */

  //   return _DataSource(appointments);
  // }

  @override
  void initState() {
    //_dataSource = _getDataSource();
    _dataSource = widget.stampList;
    super.initState();
    print(_dataSource.appointments!.length);
  }

  @override
  Widget build(BuildContext context) {
    //final MonthCellBuilder? monthCellBuilder;
    //CalendarTapDetails? calendarTapDetails;
    String? note;

    setState(() {
      note = '';
      //selectedDayDetails =
    });

    return _dataSource.appointments!.length == 0
        ? Container(
            child: Center(
              child: Text('まだスタンプがありません'),
            ),
          )
        : Column(
            children: [
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
                        offset: Offset(0, 3),
                      ),
                    ]),

                //カレンダー本体
                child: SfCalendar(
                  view: CalendarView.month,
                  //showDatePickerButton: true, //月を選べるボタン
                  onTap: calendarTapped,

                  controller: _controller,
                  dataSource: _dataSource, //これが重要
                  appointmentTimeTextFormat: 'HH:mm',

                  monthViewSettings: const MonthViewSettings(
                    dayFormat: 'EEE',
                    numberOfWeeksInView: 4, //何週を表示するのか指定
                    appointmentDisplayCount: 1, //セルの大きさを指定
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment, //ここが重要
                    showAgenda: false, //下の予定表一覧
                    navigationDirection: MonthNavigationDirection.horizontal,
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
                    final Appointment meeting = details.appointments.first;

                    if (_controller.view != CalendarView.schedule) {
                      return Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              /*
                        Container(
                          padding: EdgeInsets.all(3),
                          height: 50,
                          alignment: Alignment.topLeft,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            color: meeting.color,
                          ),
                          child: SingleChildScrollView(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meeting.subject,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                        ),
                        */

                              //ここで画像を表示させる
                              Container(
                                width: 60,
                                height: 200,
                                padding: const EdgeInsets.fromLTRB(3, 5, 3, 2),
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Image(
                                          image: ExactAssetImage(
                                              '${meeting.notes}'

                                              //'assets/images/stamps/stamp_kabotya_001.png'
                                              ),
                                          fit: BoxFit.fill,
                                          width: 100,
                                          height: 100),
                                    ),
                                    /*
                                  Text(
                                    meeting.notes!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  )
                                */
                                  ],
                                ),
                              ),

                              /*
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5)),
                            color: meeting.color,
                          ),
                        ),
                  
                        */
                            ],
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
              //スタンプ格納されてる
              Visibility(
                visible: isVisible,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
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
                  child: GridView.count(
                    primary: false,
                    //crossAxisSpacing: 10,
                    //mainAxisSpacing: 10,
                    crossAxisCount: 5,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_001_kabocha.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_001_kabocha.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_002_firststanding.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_002_firststanding.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_003_ichig.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_003_ichig.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_004_iyaiya.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_004_iyaiya.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_005_omiyamairi.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_005_omiyamairi.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_006_jagaimo.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_006_jagaimo.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_007_tomato.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_007_tomato.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_008_ninjin.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_008_ninjin.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_009_harfborthday.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_009_harfborthday.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_010_papa.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_010_papa.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_011_burokkori.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_011_burokkori.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_012_horenso.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_012_horenso.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_013_mama.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_013_mama.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_014_wakuchinfinished.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_014_wakuchinfinished.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_015_ikkagetukenshin.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_015_ikkagetukenshin.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_016_car.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_016_car.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_017_syuku100nichi.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_017_syuku100nichi.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_018_suizokukann.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_018_suizokukann.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_019_densya.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_019_densya.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_020_zoonew.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_020_zoonew.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_021_yomikikase.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_021_yomikikase.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_022_aruita.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_022_aruita.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_023_tatta.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_023_tatta.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note =
                                'assets/images/stamps/stamp_024_kamikitta.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_024_kamikitta.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            note = 'assets/images/stamps/stamp_025_tobira.png';
                          });
                          addStamp(selectedDayDetails!, note!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'assets/images/stamps/stamp_025_tobira.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //1日の記録が格納されている
              Visibility(
                visible: detailisVisible,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
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
                      /*
                Center(
                  //birthdayshow
                  child: (selectedDayDetails != null)
                      ? Text(
                          '生後${selectedDayDetails!.date!.difference(birthday).inDays}日      ${selectedDayDetails!.date!.month}月${selectedDayDetails!.date!.day}日',
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )
                      : const Text('日付をクリックしてください'),
                ),
                */
                      const SizedBox(height: 40),
                      Container(
                        child: Row(children: [
                          Container(
                            width: 100,
                            child: Expanded(
                              child: Image.asset(
                                  'assets/images/stamps/stamp_001_kabocha.png',
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ]),
                      )
                    ],
                  )),
                ),
              ),
              //下のボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 158, 201, 236),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(chagestampisVisibleview);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 161, 209, 248),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(chagedetailisVisibleview);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
  }
////////
////////
////////
////////
///////////
////////
///////////
////////
///////////
////////
///////////
////////
  ///ここからが関数リスト

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    setState(() {
      chagestampisVisibleview();
      detailisVisible = true;
    });
    setState(() {
      selectedDayDetails = calendarTapDetails;
    });
  }

  void addStamp(CalendarTapDetails selectedDayDetails, String note) {
    Appointment app = Appointment(
        startTime: selectedDayDetails.date!,
        endTime: selectedDayDetails.date!,
        subject: 'テスト中',
        notes: note);

    _dataSource.appointments!.add(app);
    _dataSource
        .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
  }

  void chagestampisVisibleview() {
    isVisible = !isVisible;
  }

  void chagedetailisVisibleview() {
    detailisVisible = !detailisVisible;
  }

/*
  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    Appointment app = Appointment(
        startTime: calendarTapDetails.date!,
        endTime: calendarTapDetails.date!,
        subject: 'テスト中',
        notes: 'assets/images/stamps/stamp_iyaiya_004.png');
    _dataSource.appointments!.add(app);
    _dataSource
        .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
  }
*/
}

class Event_detail {
  DateTime startTime;
  DateTime endTime;
  String stamppath;
  String? subject;
  String? imagepath;
  String? textmessage;

  Event_detail({
    required this.startTime,
    required this.endTime,
    required this.stamppath,
    this.subject,
    this.imagepath,
    this.textmessage,
  });
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
//生後の記録を登録して候補を表示させる
//スタンプに重みデータを載せる
