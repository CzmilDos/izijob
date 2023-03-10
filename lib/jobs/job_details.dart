import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/jobs/jobs_screen.dart';
import 'package:linkedin_clone/services/global_methods.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/comments_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';


class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({required this.uploadedBy, required this.jobId});
  final String uploadedBy;
  final String jobId;

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {

  TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
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

  applyForJob(){
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query: 'subject=Postulation pour l\'offre : $jobTitle&body=Salut, ci-joint mon CV',
    );
    final url = params.toString();
    launch(url);
    addNewApplicant();
  }

  void addNewApplicant() async{
    var docRef = FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);

    docRef.update({
      "applicants": applicants + 1
    });
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobScreen()));
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

                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: TextStyle(
                                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '  Postulants ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.deepOrangeAccent,
                            )
                          ],
                      ),

                      FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy ?
                          Container():
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dividerWidget(),
                              Text(
                                'Recrutement: ',
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
                                      User? user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if(_uid == widget.uploadedBy){
                                        try{
                                          FirebaseFirestore.instance
                                              .collection('jobs')
                                              .doc(widget.jobId)
                                              .update({'recruitment': true});
                                        }catch(err){
                                          GlobalMethod.showErrorDialog(
                                              error: 'Une erreur s\'est produite',
                                              ctx: context
                                          );
                                        }
                                      }else{
                                        GlobalMethod.showErrorDialog(
                                            error: 'Vous ne pouvez pas executer cette action',
                                            ctx: context
                                        );
                                      }
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
                                      opacity: recruitment == true ? 1 : 0,
                                    child: Icon(
                                      Icons.check_box,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 40,),
                                  TextButton(
                                    onPressed: (){
                                      User? user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if(_uid == widget.uploadedBy){
                                        try{
                                          FirebaseFirestore.instance
                                              .collection('jobs')
                                              .doc(widget.jobId)
                                              .update({'recruitment': false});
                                        }catch(err){
                                          GlobalMethod.showErrorDialog(
                                              error: 'Une erreur s\'est produite',
                                              ctx: context
                                          );
                                        }
                                      }else{
                                        GlobalMethod.showErrorDialog(
                                            error: 'Vous ne pouvez pas executer cette action',
                                            ctx: context
                                        );
                                      }
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
                                    opacity: recruitment == false ? 1 : 0,
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
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8,),
                      Center(
                        child: Text(
                            isDeadlineAvailable ? 'Recrutement en cours, envoyez votre CV'
                                : 'Date limite d??j?? pass??e!',
                          style: TextStyle(
                            color: isDeadlineAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          )
                        ),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: MaterialButton(
                          onPressed: (){
                            applyForJob();
                          },
                          color: Colors.blueAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Postuler maintenant',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17
                              ),
                            ),
                          ),
                        ),
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ajout??e le: ',
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
                      dividerWidget(),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      AnimatedSwitcher(duration: Duration(
                        milliseconds: 500
                      ),
                        child: _isCommenting ?
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 3,
                              child: TextField(
                                controller: _commentController,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900
                                ),
                                maxLength: 200,
                                keyboardType: TextInputType.text,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xff5dade2),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: MaterialButton(
                                      onPressed: () async{
                                        if(_commentController.text.length < 7){
                                          GlobalMethod.showErrorDialog(
                                              error: 'Un commentaire doit exc??der 7 caract??res...',
                                              ctx: context
                                          );
                                        }else{
                                           final _generatedId = Uuid().v4();
                                           await FirebaseFirestore.instance
                                               .collection('jobs')
                                               .doc(widget.jobId)
                                               .update({
                                             'jobComments':
                                                 FieldValue.arrayUnion([
                                                   {
                                                     'userId': FirebaseAuth.instance.currentUser!.uid,
                                                     'commentId': _generatedId,
                                                     'name': name,
                                                     'userImageUrl': userImage,
                                                     'commentBody': _commentController.text,
                                                     'time': Timestamp.now(),
                                                   }
                                                 ])
                                           });
                                           await Fluttertoast.showToast(
                                             msg: 'Votre commentaire a ??t?? ajout??.',
                                             toastLength: Toast.LENGTH_LONG,
                                             backgroundColor: Colors.blue[200],
                                             fontSize: 18
                                           );
                                           _commentController.clear();
                                        }
                                        setState(() {
                                          showComment = true;
                                        });
                                      },
                                      color: Colors.blueAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Text(
                                        'Poster',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                        showComment = false;
                                      });
                                    },
                                    child: Text('Annuler', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            )
                          ],
                        ) : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isCommenting = !_isCommenting;
                                });
                              },
                              icon: Icon(
                                Icons.add_comment,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                            SizedBox(width: 10,),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showComment = true;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_circle,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                          ],
                        )
                      ),

                    showComment == false ? Container() :
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                              .collection('jobs')
                              .doc(widget.jobId)
                              .get(),
                            builder: (context, snapshot){
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return Center(child: CircularProgressIndicator());
                              }else{
                                if (snapshot.data == null){
                                  Center(child: Text(
                                      'Aucun commentaire pour ce post...')
                                  );
                                }
                              }
                              return ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index){
                                    return CommentWidget(
                                        commentId: snapshot.data!['jobComments'][index]['commentId'],
                                        commenterId: snapshot.data!['jobComments'][index]['userId'],
                                        commenterName: snapshot.data!['jobComments'][index]['name'],
                                        commentBody: snapshot.data!['jobComments'][index]['commentBody'],
                                        commenterImageUrl: snapshot.data!['jobComments'][index]['userImageUrl']
                                    );
                                  },
                                  separatorBuilder: (context, index){
                                    return Divider(
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    );
                                  },
                                  itemCount: snapshot.data!['jobComments'].length
                              );
                            },
                          ),
                        ),

                  ],
                ),
              ),
            )

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
