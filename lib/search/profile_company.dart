import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:linkedin_clone/authentification/login.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {

  final String userID;

  const ProfileScreen({required this.userID});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String phoneNumber = '';
  String email = "";
  String? name;
  String imageUrl = '';
  String joinedAt = " ";
  bool _isSameUser = false;

  void getUserData() async{
    try{
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userID)
        .get();
      if(userDoc == null){
        return;
      }else{
        setState(() {
          email = userDoc.get('email');
          name = userDoc.get('name');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          Timestamp joinedAtTimeStamp = userDoc.get('creationDate');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.day}-${joinedDate.month}-${joinedDate.year}';
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userID;
        });
      }
    }catch(error) {} finally{
      _isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: AppBottomNavigationBar(indexNum: 3,),
      body: Center(
        child: _isLoading ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Card(
                      elevation: 20,
                      color: Colors.white,
                      margin: EdgeInsets.all(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 100,),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                name == null ? 'Nom': name!,
                                style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)
                              ),
                            ),
                            SizedBox(height: 15,),
                            Divider(
                              thickness: 3,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 15,),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Informations sur le compte :',
                                style: TextStyle(color: Colors.black, fontSize: 22),
                              ),
                            ),
                            SizedBox(height: 15,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: userInfo(icon: Icons.email, content: email,),
                            ),
                            SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: userInfo(icon: Icons.phone_android, content: phoneNumber),
                            ),
                            SizedBox(height: 30,),
                            Divider(
                              thickness: 3,
                              color: Colors.grey[300],
                            ),
                            _isSameUser ?Container()

                                : Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _contactBy(
                                            color: Colors.green,
                                            fct: (){
                                              _openWhatsAppChat();
                                            },
                                            icon: FontAwesome.whatsapp
                                        ),
                                        _contactBy(
                                            color: Colors.red,
                                            fct: (){
                                              _mailTo();
                                            },
                                            icon: Icons.mail_outline
                                        ),
                                        _contactBy(
                                            color: Colors.purple,
                                            fct: (){
                                              _callPhoneNumber();
                                            },
                                            icon: Icons.call_outlined
                                        ),
                                      ],
                                    ),
                                ),
                            SizedBox(height: 10,),
                            Divider(thickness: 3, color: Colors.grey[300],),
                            SizedBox(height: 25,),
                            !_isSameUser ? Container() : Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: MaterialButton(
                                  onPressed: (){
                                    _auth.signOut();
                                    Navigator.push(
                                        context, MaterialPageRoute(
                                        builder: (context) => Login()));
                                  },
                                  color: Colors.blue[300],
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Se deconnecter ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Icon(
                                          Icons.logout_outlined,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.26,
                      height: size.height * 0.26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 8,
                          color: Theme.of(context).scaffoldBackgroundColor
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            imageUrl == null
                                ? ''
                                : imageUrl
                          ),
                          fit: BoxFit.fill
                        )
                      ),
                    )
                  ],
                ),
              ],
            ),
        )
      ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=Salut, ';
    launch(url, forceWebView: false);
  }

  void _mailTo() async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Ecrivez le sujet ici...&body=Salut, ',
    );
    final url = params.toString();
    launch(url);
  }

  void _callPhoneNumber() async {
    final url = '$phoneNumber';
    await FlutterPhoneDirectCaller.callNumber(url);
  }

  Widget _contactBy(
      {required Color color, required Function fct, required IconData icon}
      ){
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: (){
            fct();
          },
        ),
      ),
    );
  }

  Widget userInfo({required IconData icon, required String content}){
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue[600],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
        ),
      ],
    );
  }

}
