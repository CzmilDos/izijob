import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/authentification/login.dart';
import 'package:linkedin_clone/jobs/jobs_screen.dart';
import 'package:linkedin_clone/jobs/upload_job.dart';
import 'package:linkedin_clone/search/profile_company.dart';
import 'package:linkedin_clone/search/search_companies.dart';
import 'package:linkedin_clone/user_state.dart';

class AppBottomNavigationBar extends StatelessWidget {

  int indexNum = 0;
  AppBottomNavigationBar({required this.indexNum});

  void _logout(context){
    final FirebaseAuth _auth = FirebaseAuth.instance;
    
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.black,
                    size: 36,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                )
              ],
            ),
            content: Text(
              'Voulez-vous vous déconnecter de l\'application ?',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Text('Non', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),),
              ),
              TextButton(
                onPressed: (){
                  _auth.signOut();
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text('Oui', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
        color: Colors.blue,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.blue,
        height: 52,
        index: indexNum,
        items:<Widget>[
          Icon(Icons.list,size: 26,color: Colors.white,),
          Icon(Icons.search,size: 26,color: Colors.white,),
          Icon(Icons.add,size: 26,color: Colors.white,),
          Icon(Icons.person_pin,size: 26,color: Colors.white,),
          Icon(Icons.exit_to_app,size: 26 ,color: Colors.white,),
        ],

        animationDuration: Duration(
          milliseconds: 300,
        ),
        animationCurve: Curves.bounceInOut,
        onTap: (index){
          if (index == 0){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobScreen()));
          }
          else if (index == 1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WorkersScreen()));
          }
          else if (index ==2){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UploadJob()));
          }
          else if (index == 3){
            final FirebaseAuth _auth = FirebaseAuth.instance;
            final User? user = _auth.currentUser;
            final String uid = user!.uid;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen(
                userID: uid
            )));
          }
          else if (index == 4){
            _logout(context);
          }
        },
    );
  }
}
