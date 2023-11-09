import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

class CustomStampPage extends StatefulWidget {
  const CustomStampPage({super.key});

  @override
  State<CustomStampPage> createState() => _CustomStampPageState();
}

class _CustomStampPageState extends State<CustomStampPage> {
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> storeImage() async {
    screenshotController.capture().then((capturedImage) async {
      if (capturedImage != null) {
        await ImageGallerySaver.saveImage(capturedImage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタンプを作成'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('スタンプを作成'),
          ],
        ),
      ),
    );
  }
}
