import 'package:flutter/material.dart';
import 'package:hazimetecalendar/pages/consultation_page.dart';
import 'package:hazimetecalendar/pages/home_page.dart';
import 'package:hazimetecalendar/pages/profile_edit_page.dart';
import 'package:hazimetecalendar/pages/setting_page.dart';
import 'package:hazimetecalendar/provider/usr_provider.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String username = '';
  int _page = 0;
  late PageController pageController;
  final homeScreenItems = [SearchPage(), HomePage(), SettingPage()];

  //userのuidを認識させるコード　ちょう重要
  @override
  void initState() {
    super.initState();
    addData();
    pageController = PageController();
  }

  addData() async {
    //特にこのコードが重要！！！！
    UserProvider _useProvider = Provider.of(context, listen: false);
    await _useProvider.refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void getUsername() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      username = (snap.data() as Map<String, dynamic>)['username'];
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: PageView(
        children: homeScreenItems,
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        height: 70,
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: _page == 0 ? primaryColor : secondaryColor,
              ),
              label: '子育てに困ったら',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: _page == 1 ? primaryColor : secondaryColor,
              ),
              label: 'ホーム',
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.settings_outlined,
                color: _page == 2 ? primaryColor : secondaryColor,
              ),
              label: '設定',
              backgroundColor: primaryColor),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}






  /*
  int _currentIndex = 1;
  final _pageWidgets = [SearchPage(), const HomePage(), SettingPage()];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageWidgets.elementAt(_currentIndex),

      //アプリの下のアイコンたち
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mobileBackgroundColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '子育てに困ったら'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: '設定'),
        ],
        currentIndex: _currentIndex,
        fixedColor: buttoncolor2,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
*/