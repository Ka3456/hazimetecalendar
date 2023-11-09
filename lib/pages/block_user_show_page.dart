import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hazimetecalendar/utils/colors.dart';

class BlockUserShowPage extends StatefulWidget {
  List<dynamic> blocking;
  BlockUserShowPage({super.key, required this.blocking});

  @override
  State<BlockUserShowPage> createState() => _BlockUserShowPageState();
}

class _BlockUserShowPageState extends State<BlockUserShowPage> {
  unblockuser(String blockeduseruid, String blockinguseruid) {
    //ブロックを解除する
    FirebaseFirestore.instance.collection('users').doc(blockinguseruid).update({
      'blocking': FieldValue.arrayRemove([blockeduseruid])
    });
    FirebaseFirestore.instance.collection('users').doc(blockeduseruid).update({
      'blocked': FieldValue.arrayRemove([blockinguseruid])
    });
    print('$blockeduseruidのブロックを$blockinguseruidが解除しました');
  }

  @override
  void initState() {
    super.initState();
    //getData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(widget.blocking);
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('ブロックユーザー一覧'),
      ),
      body: ListView.builder(
        itemCount: widget.blocking.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.blocking[index])
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.hasData && !snapshot.data!.exists) {
                  return const Text('');
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          color: secondaryColor),
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(data['photoUrl']),
                            ),
                            SizedBox(
                              width: size.width * 0.05,
                            ),
                            Text(
                              data['username'],
                              style: TextStyle(fontSize: size.width * 0.06),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.block),
                            onPressed: () {
                              //AleartDialogでブロックを解除するか
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('ブロックを解除しますか？'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('キャンセル')),
                                        TextButton(
                                            onPressed: () {
                                              unblockuser(
                                                  data['uid'],
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('解除')),
                                      ],
                                    );
                                  });
                            }),
                      ),
                    ),
                  );
                }

                return const Text('loading');
              });
        },
      ),
    );
  }
}
