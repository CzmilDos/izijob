import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkedin_clone/user_state.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IziJob',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xfff2f3f4),
        primarySwatch: Colors.blue,
      ).copyWith(
        textTheme: GoogleFonts.robotoSlabTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: UserState(),
    );
  }

}

