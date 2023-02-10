import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/services/global_methods.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/comments_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'admin_screen.dart';


class AdminJobDetailsScreen extends StatefulWidget {
  const AdminJobDetailsScreen({required this.uploadedBy, required this.jobId});
  final String uploadedBy;
  final String jobId;

  @override
  _AdminJobDetailsScreenState createState() => _AdminJobDetailsScreenState();
}

class _AdminJobDetailsScreenState extends State<AdminJobDetailsScreen> {

  TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  bool? isValidated;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = "";
  String? emailCompany = "";
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;

  @override
  void initState() {
    super.initState();
    getJobData();
  }

  void getJobData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null){
      return;
    }else{
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
    if(jobDatabase == null){
      return;
    }else{
      setState(() {
        jobTitle = jobDatabase.get('jobTitle');
        jobDescription = jobDatabase.get('jobDescription');
        recruitment = jobDatabase.get('recruitment');
        isValidated = jobDatabase.get('isValidated');
        emailCompany = jobDatabase.get('email');
        locationCompany = jobDatabase.get('location');
        applicants = jobDatabase.get('applicants');
        postedDateTimeStamp = jobDatabase.get('createdAt');
        deadlineDateTimeStamp = jobDatabase.get('deadLineDateTimeStamp');
        deadlineDate = jobDatabase.get('deadLineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.day}-${postDate.month}-${postDate.year}';
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded, size: 35, color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminScreen()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          jobTitle == null? '' : jobTitle!,
                          maxLines: 3,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: Colors.white,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ? ''
                                        : userImageUrl!,
                                  ),
                                  fit: BoxFit.fill
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName == null ? '' : authorName!,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  locationCompany!,
                                  style: TextStyle(color: Colors.black87),
                                )
                              ],
                            ),
                          )
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dividerWidget(),
                          Text(
                            'Validation: ',
                            style: TextStyle(
                                fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: (){
                                  FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(widget.jobId)
                                      .update({'isValidated': true});
                                  getJobData();
                                },
                                child: Text(
                                  'Oui',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: isValidated == true ? 1 : 0,
                                child: Icon(
                                  Icons.check_box,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 40,),
                              TextButton(
                                onPressed: (){
                                  FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(widget.jobId)
                                      .update({'isValidated': false});
                                  getJobData();
                                },
                                child: Text(
                                  'Non',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: isValidated == false ? 1 : 0,
                                child: Icon(
                                  Icons.check_box,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),

                      dividerWidget(),
                      Text(
                        'Description: ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        jobDescription == null ? '' : jobDescription!,
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ajoutée le: ',
                            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            postedDate == null ? '' : postedDate!,
                            style: TextStyle(
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date limite: ',
                            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            deadlineDate == null ? '' : deadlineDate!,
                            style: TextStyle(
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12,),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget dividerWidget() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 4,
          color: Colors.grey[300],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
