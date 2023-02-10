import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/persistence/persistance.dart';
import 'package:linkedin_clone/search/search_job.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';
import 'package:linkedin_clone/widgets/job_widget.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  _JobScreenState createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {

  String? jobCategoryFilter;

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
      bottomNavigationBar: AppBottomNavigationBar(indexNum: 0,),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.filter_list_outlined,
            color: Colors.white,
            size: 24,
          ),
          onPressed: _showJobCategoryDialog,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_outlined,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => SearchScreen()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('jobCategory', isEqualTo: jobCategoryFilter)
            .where('recruitment', isEqualTo: true)
            .where('isValidated', isEqualTo: true)
            .orderBy('createdAt', descending: true)
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
                  return JobWidget(
                      jobTitle: snapshot.data?.docs[index]['jobTitle'],
                      jobDescription: snapshot.data!.docs[index]['jobDescription'],
                      jobId: snapshot.data?.docs[index]['jobId'],
                      uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                      userImage: snapshot.data?.docs[index]['userImage'],
                      name: snapshot.data?.docs[index]['name'],
                      recruitment: snapshot.data?.docs[index]['recruitment'],
                      email: snapshot.data?.docs[index]['email'],
                      location: snapshot.data?.docs[index]['location']
                  );
                }
              );
            }else{
              return Center(
                child: Text(
                  'Aucune offre trouvée',
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

  _showJobCategoryDialog(){
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            backgroundColor: Colors.black,
            title: Text(
              'Catégories d\'emploi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            content: Container(
              width: 600.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistance.jobCategoryList.length,
                itemBuilder: (ctx, index){
                  return InkWell(
                    onTap: (){
                      setState(() {
                        jobCategoryFilter = Persistance.jobCategoryList[index];
                      });
                      Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                      print(
                        'jobCategoryList[index], ${Persistance.jobCategoryList[index]}'
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_right_outlined,
                          color: Colors.grey[300],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistance.jobCategoryList[index],
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                },
                child: Text('Fermer', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
              TextButton(
                onPressed: (){
                  setState(() {
                    jobCategoryFilter = null;
                  });
                  Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                },
                child: Text('Annuler', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ],
          );
        }
    );
  }


}
