import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/services/global_methods.dart';

import 'login.dart';

class ForgotPassScreen extends StatefulWidget {
  @override
  _ForgotPassScreenState createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  late TextEditingController _emailTextController = TextEditingController(text: '');
  final _loginFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hintText = 'Email';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded, size: 35, color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50, top: 30),
          child: Card(
            elevation: 16,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Text(
                        'Réinitialiser le mot de passe',
                        style: TextStyle(
                          color: Colors.indigoAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextController,
                      validator: (value){
                        if(value!.isEmpty || !value.contains("@")){
                          return "Veuillez renseigner une email valide !";
                        }else{
                          return null;
                        }
                      },
                      style: TextStyle(
                        color: Colors.blueGrey[800],
                      ),
                      decoration: InputDecoration(

                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.blue,
                        ),

                        labelText: hintText,
                        labelStyle: TextStyle(color: Colors.black54, fontSize: 20),
                        hintStyle: TextStyle(color: Colors.black87, fontSize: 20),
                        filled: true,
                        fillColor: Colors.blueGrey[50],
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
                    child: _isLoading? CircularProgressIndicator(): MaterialButton(
                      onPressed: resetPassword,
                      color: Colors.blue,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Réinitialiser',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                              ),

                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetPassword() async {
    final isValid = _loginFormKey.currentState!.validate();
    if(isValid) {
      setState(() {
        _isLoading = true;
      });
      try{
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailTextController.text).then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  title: Text('Lien de réinitialisation envoyé!'),
                  content: Text(
                      'Veuillez cliquer sur le lien envoyé à votre adresse email pour réinitialiser votre mot de passe.'),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Ok"),)
                  ],
                )
        );
      });
    }catch (error){
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(
            error: error.toString(), ctx: context);
        print('Une erreur s\'est produite: $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}