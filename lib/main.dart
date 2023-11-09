import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hazimetecalendar/firebase_options.dart';
import 'package:hazimetecalendar/pages/first_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hazimetecalendar/pages/root_page.dart';
import 'package:hazimetecalendar/provider/usr_provider.dart';
import 'package:hazimetecalendar/utils/colors.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'はじめてカレンダー：β版',
        theme: ThemeData(
          //primaryColor: Colors.red,
          textTheme:
              GoogleFonts.zenMaruGothicTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 101, 174, 234)),
          useMaterial3: true,
        ),
        locale: const Locale('ja'),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const MainPage();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }

            return const FirstPage();
          },
        ),
      ),
    );
  }
}
