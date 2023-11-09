import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hazimetecalendar/pages/block_user_show_page.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:hazimetecalendar/widget/profile_edit_widget.dart';
import 'package:hazimetecalendar/widget/text_field_input.dart';
import 'package:url_launcher/url_launcher.dart';

//password: unavailable, following: [], blocking: [VewnbHG6Z0fhbH22YCzuDoAWKFS2], uid: HPb2uCLy8QT5SjTN4CBdbvfuEPj1, followers: [VewnbHG6Z0fhbH22YCzuDoAWKFS2], email: test31@gmail.com, blocked: [], photoUrl: followers:
class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  bool usernameeditor = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      //既にある場合は削除

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        //ない場合は追加
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  blockuser(String blockeduseruid, String blockinguseruid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(userData['uid']).get();
      //List blocking = (snap.data()! as dynamic)['blocking'];

      //ない場合は追加
      //自分のブロックリストに追加
      await _firestore.collection('users').doc(blockinguseruid).update({
        'blocking': FieldValue.arrayUnion([blockeduseruid])
      });
      //相手のブロックリストに追加
      await _firestore.collection('users').doc(blockeduseruid).update({
        'blocked': FieldValue.arrayUnion([blockinguseruid])
      });
      //フォローされている場合はフォローを外す
      await _firestore.collection('users').doc(blockinguseruid).update({
        'followers': FieldValue.arrayRemove([blockeduseruid])
      });
      //フォローしているばあいはフォローを外す
      await _firestore.collection('users').doc(blockinguseruid).update({
        'following': FieldValue.arrayRemove([blockeduseruid])
      });

      //相手のフォロワーから削除
      await _firestore.collection('users').doc(blockeduseruid).update({
        'following': FieldValue.arrayRemove([blockinguseruid])
      });
      //相手のフォローから削除
      await _firestore.collection('users').doc(blockeduseruid).update({
        'followers': FieldValue.arrayRemove([blockinguseruid])
      });
      getData();
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print('buildスターと');

    print(userData);

    return isLoading
        ? Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                //上のユーザー情報
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                  userData['photoUrl'],
                                ),
                                radius: 40,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(followers, "フォロワー"),
                                    buildStatColumn(following, "フォロー中"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      (ProfileEditWidget(userData: userData))),
                            );
                          },
                          child: const Text(
                            'プロフィールを編集',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: TextButton(
                          onPressed: () {
                            userData['blocking'].isNotEmpty
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            (BlockUserShowPage(
                                              blocking: userData['blocking'],
                                            ))))
                                : showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('ブロックユーザーはいません'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'))
                                        ],
                                      );
                                    });
                          },
                          child: const Text(
                            'ブロックリスト',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Center(
                    child: Text(
                      'フォロワー(他人がフォローしてる)',
                      style: TextStyle(fontSize: size.width * 0.05),
                    ),
                  ),
                ),
                //フォロワー（他人がフォローしてる）
                userData['followers'].isEmpty
                    ? const Center(
                        child: Text('No followers yet'),
                      )
                    : Column(
                        children: List.generate(
                          userData['followers'].length,
                          (index) => FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .where('uid',
                                    isEqualTo: userData['followers'][index])
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              DocumentSnapshot snap =
                                  (snapshot.data! as dynamic).docs[0];
                              return GestureDetector(
                                onTap: () {
                                  //
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
                                                  backgroundImage: NetworkImage(
                                                    snap['photoUrl'],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.03,
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.04,
                                                  child: Text(
                                                    snap['username'],
                                                    style: TextStyle(
                                                        fontSize:
                                                            size.height * 0.03),
                                                  )),
                                              SizedBox(
                                                height: size.height * 0.04,
                                              ),

                                              //
                                              SizedBox(
                                                height: size.height * 0.07,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    buildStatColumn(
                                                        snap['followers']
                                                            .length,
                                                        "フォロワー"),
                                                    buildStatColumn(
                                                        snap['following']
                                                            .length,
                                                        "フォロー中"),
                                                  ],
                                                ),
                                              ),
                                              //
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Center(
                                            child: ElevatedButton(
                                              child: Text(
                                                'ブロックする',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.height * 0.02),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        '${snap['username']}さんをブロックしますか？',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                'キャンセル')),
                                                        TextButton(
                                                            onPressed: () {
                                                              blockuser(
                                                                  snap['uid'],
                                                                  userData[
                                                                      'uid']);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                'ブロックする'))
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Center(
                                            child: ElevatedButton(
                                              child: Text(
                                                '通報する',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.height * 0.02),
                                              ),
                                              onPressed: () {
                                                final url = Uri.parse(
                                                    'https://forms.gle/uSqbFhVbe7cSUPXn8');
                                                launchUrl(url);
                                              },
                                            ),
                                          ),
                                          Center(
                                            child: ElevatedButton(
                                              child: Text(
                                                'キャンセル',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.height * 0.02),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  //
                                },
                                child: Container(
                                  child: Row(children: [
                                    SizedBox(
                                      width: size.width * 0.2,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.02),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          backgroundImage: NetworkImage(
                                            snap['photoUrl'],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(snap['username']),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.2,
                                    ),

                                    //フォローされてるかどうかsnap['followers'].contains(
                                    //FirebaseAuth.instance.currentUser!.uid)
                                    if (userData['following']
                                        .contains(snap['uid']))
                                      Container(
                                        width: size.width * 0.4,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['followers'][index],
                                              );
                                              setState(() {
                                                userData['following'].remove(
                                                    //userData['following']
                                                    //   [index]
                                                    snap['uid']);
                                                following--;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 199, 243, 191),
                                            ),
                                            child: Text(
                                              'フォロー中',
                                              style: TextStyle(
                                                  fontSize: size.width * 0.03),
                                            )),
                                      )
                                    else
                                      Container(
                                        width: size.width * 0.4,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            followUser(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['followers'][index],
                                            );

                                            setState(() {
                                              userData['following'].add(
                                                  //userData['followers'][index]
                                                  snap['uid']);
                                              following++;
                                              userData;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 176, 198, 255),
                                          ),
                                          child: Text(
                                            'フォローする',
                                            style: TextStyle(
                                                fontSize: size.width * 0.03),
                                          ),
                                        ),
                                      ),
                                  ]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Divider(
                    color: Colors.black,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Center(
                    child: Text(
                      'フォロー中(自分がフォローしてる)',
                      style: TextStyle(fontSize: size.width * 0.05),
                    ),
                  ),
                ),
                //フォロー中（自分がフォローしてる）
                userData['following'].isEmpty
                    ? const Center(
                        child: Text('No following yet'),
                      )
                    : SizedBox(
                        height: size.height * 0.2,
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              userData['following'].length,
                              (index) => FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('uid',
                                        isEqualTo: userData['following'][index])
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  DocumentSnapshot snap =
                                      (snapshot.data! as dynamic).docs[0];
                                  return GestureDetector(
                                    onTap: () {
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
                                                      backgroundColor:
                                                          Colors.grey,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        snap['photoUrl'],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: size.height * 0.03,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.04,
                                                      child: Text(
                                                        snap['username'],
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.height *
                                                                    0.03),
                                                      )),
                                                  SizedBox(
                                                    height: size.height * 0.04,
                                                  ),

                                                  //
                                                  SizedBox(
                                                    height: size.height * 0.07,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        buildStatColumn(
                                                            snap['followers']
                                                                .length,
                                                            "フォロワー"),
                                                        buildStatColumn(
                                                            snap['following']
                                                                .length,
                                                            "フォロー中"),
                                                      ],
                                                    ),
                                                  ),
                                                  //
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Center(
                                                child: ElevatedButton(
                                                  child: Text(
                                                    'ブロックする',
                                                    style: TextStyle(
                                                        fontSize:
                                                            size.height * 0.02),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            '${snap['username']}さんをブロックしますか？',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'キャンセル')),
                                                            TextButton(
                                                                onPressed: () {
                                                                  blockuser(
                                                                      snap[
                                                                          'uid'],
                                                                      userData[
                                                                          'uid']);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'ブロックする'))
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              Center(
                                                child: ElevatedButton(
                                                  child: Text(
                                                    '通報する',
                                                    style: TextStyle(
                                                        fontSize:
                                                            size.height * 0.02),
                                                  ),
                                                  onPressed: () {
                                                    final url = Uri.parse(
                                                        'https://forms.gle/uSqbFhVbe7cSUPXn8');
                                                    launchUrl(url);
                                                  },
                                                ),
                                              ),
                                              Center(
                                                child: ElevatedButton(
                                                  child: Text(
                                                    'キャンセル',
                                                    style: TextStyle(
                                                        fontSize:
                                                            size.height * 0.02),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      child: Row(children: [
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                size.width * 0.02),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              backgroundImage: NetworkImage(
                                                snap['photoUrl'],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(snap['username']),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.2,
                                        ),

                                        //フォローされてるかどうか
                                        //snap['followers'].contains(FirebaseAuth
                                        //  .instance.currentUser!.uid)

                                        if (userData['followers']
                                                .contains(snap['uid']) ==
                                            false)
                                          Container(
                                            width: size.width * 0.4,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['following']
                                                        [index],
                                                  );
                                                  setState(() {
                                                    userData['following'].remove(
                                                        snap['uid']

                                                        //userData['following']
                                                        //  [index]

                                                        );
                                                    following--;
                                                    userData;
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            176,
                                                            198,
                                                            255)),
                                                child: Text(
                                                  'フォローなし\nフォローを外す',
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.width * 0.03),
                                                )),
                                          )
                                        else
                                          Container(
                                            width: size.width * 0.4,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                followUser(
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  userData['following'][index],
                                                );
                                                setState(() {
                                                  userData['following']
                                                      .remove(snap['uid']);
                                                  following--;
                                                  userData;
                                                  //getData();
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 199, 243, 191),
                                              ),
                                              child: Text(
                                                '相互フォロー\nフォローを外す',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * 0.03),
                                              ),
                                            ),
                                          ),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
