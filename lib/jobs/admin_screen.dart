import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/authentification/login.dart';
import 'package:linkedin_clone/search/search_job.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/user_state.dart';
import 'package:linkedin_clone/widgets/admin_job_widget.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getMyData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      location = userDoc.get('location');
    });
  }

  @override
  void initState() {
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
            onPressed: (){
              _auth.signOut();
              Navigator.canPop(context) ? Navigator.pop(context) : null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('isValidated', isEqualTo: false)
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          else if(snapshot.connectionState == ConnectionState.active){
            if(snapshot.data?.docs.isNotEmpty == true){
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    return AdminJobWidget(
                        jobTitle: snapshot.data?.docs[index]['jobTitle'],
                        jobDescription: snapshot.data!.docs[index]['jobDescription'],
                        jobId: snapshot.data?.docs[index]['jobId'],
                        uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                        userImage: snapshot.data?.docs[index]['userImage'],
                        name: snapshot.data?.docs[index]['name'],
                        recruitment: snapshot.data?.docs[index]['recruitment'],
                        isValidated: snapshot.data?.docs[index]['isValidated'],
                        email: snapshot.data?.docs[index]['email'],
                        location: snapshot.data?.docs[index]['location']
                    );
                  }
              );
            }else{
              return Center(
                child: Text(
                  'Aucune offre en attente',
                  style: TextStyle(color: Colors.black87, fontSize: 22),
                ),
              );
            }
          }
          return Center(
            child: Text(
              'Une erreur s\'est produite',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30
              ),
            ),
          );
        },
      ),
    );
  }


}
