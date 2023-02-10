import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:linkedin_clone/search/profile_company.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkersWidget extends StatefulWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImageUrl;

  const WorkersWidget({
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.phoneNumber,
    required this.userImageUrl
  });

  @override
  _WorkersWidgetState createState() => _WorkersWidgetState();
}

class _WorkersWidgetState extends State<WorkersWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
      ),
      elevation: 8,
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen(
            userID: widget.userID
          )));
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.userImageUrl == null ?
            ''
            : widget.userImageUrl
            ),
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Consulter le profil",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.mail_outline,
            size: 30,
            color: Colors.black54,
          ),
          onPressed: _mailTo,
        ),
      ),
    );
  }

  void _mailTo() async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: widget.userEmail,
      query: 'subject=Ecrivez le sujet ici...&body=Salut, ',
    );
    final url = params.toString();
    launch(url);
  }

}
