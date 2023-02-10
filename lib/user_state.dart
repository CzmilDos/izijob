import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authentification/login.dart';
import 'jobs/admin_screen.dart';
import 'jobs/jobs_screen.dart';

class UserState extends StatefulWidget {

  @override
  _UserStateState createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {

  String role = 'user';

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  void _checkRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    final DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    setState(() {
      role = snap['role'];
    });

    if(role == 'user'){
      navigateNext(JobScreen());
    }else if(role == 'admin'){
      navigateNext(AdminScreen());
    }
  }

  void navigateNext(Widget route){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => route ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot){
          if(userSnapshot.data == null){
            return Login();
          }
          else if(userSnapshot.hasData && role == 'user'){
            return JobScreen();
          }
          else if(userSnapshot.hasData && role == 'admin'){
            return AdminScreen();
          }
          else if(userSnapshot.connectionState == ConnectionState.waiting){
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            body: Center(
              child: Text('Une erreur s\'est produite, veuillez réessayez!'),
            ),
          );
        }
    );
  }
}
