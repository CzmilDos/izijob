import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/jobs/job_details.dart';
import 'package:linkedin_clone/services/global_methods.dart';

class JobWidget extends StatefulWidget {

  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;

  const JobWidget({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
  });

  @override
  _JobWidgetState createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      color: Colors.white,
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(
              uploadedBy: widget.uploadedBy, jobId: widget.jobId,
          )));
        },
        onLongPress: _deleteDialog,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                width: 1
              ),
            ),
          ),
          child: Image.network(widget.userImage),
        ),
        title: Text(
          widget.jobTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8,),
            Text(
              widget.jobDescription,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black54,
        ),
      ),
    );
  }

  _deleteDialog(){
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () async{
                    try{
                      if(widget.uploadedBy == _uid){
                        await FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(widget.jobId)
                            .delete();
                        await Fluttertoast.showToast(
                          msg: "Cette offre a été supprimé",
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.grey[400],
                          fontSize: 18,
                        );
                        Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                      }
                      else{
                        GlobalMethod.showErrorDialog(error: "Vous ne pouvez pas supprimer cette offre !", ctx: ctx);
                      }
                    }
                    catch (error){
                      GlobalMethod.showErrorDialog(error: "Ce job ne peut pas être supprimé...", ctx: context);
                    }finally{}
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      Text(
                        'Supprimer',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                    ],
                  )
              ),
            ],
          );
        }
    );
  }

}
