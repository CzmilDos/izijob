import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/authentification/forgotten_pwd.dart';
import 'package:linkedin_clone/authentification/registration.dart';
import 'package:linkedin_clone/services/global_methods.dart';
import 'package:linkedin_clone/user_state.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {

  late TextEditingController _emailTextController = TextEditingController(text: '');
  late TextEditingController _passTextController = TextEditingController(text: '');

  FocusNode _passFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose(){
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if(isValid){
      setState(() {
        _isLoading = true;
      });
      try{
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim(),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserState()));
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final String hintText2 = 'Email';
    final String hintText3 = 'Mot de passe';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Se connecter',
                  style: TextStyle(
                    color: Colors.indigoAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 35, right: 35, top: 135),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                    child: Image.asset("assets/images/login.png"),
                  ),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
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

                            labelText: hintText2,
                            labelStyle: TextStyle(color: Colors.blueGrey, fontSize: 20),
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 20),
                            filled: true,
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
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          validator: (value){
                            if(value!.isEmpty ){
                              return "Veuillez entrer votre mot de passe!";
                            }else if(value.length < 7){
                              return "Mot de passe incorrect";
                            }else{
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.blueGrey[800]),
                          decoration: InputDecoration(

                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: Colors.blue,
                            ),

                            suffixIcon: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                            ),

                            labelText: hintText3,
                            labelStyle: TextStyle(color: Colors.blueGrey, fontSize: 20),
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 20),
                            filled: true,
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
                        SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassScreen())
                              );
                            },
                            child: Text(
                              'Mot de pass oublié?',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _isLoading? CircularProgressIndicator():
                        MaterialButton(
                          onPressed: _submitFormOnLogin,
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
                                  'Se connecter',
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
                        SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Pas de compte?',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),
                                ),
                                TextSpan(
                                    text: '   '
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => SignUp())
                                    ),
                                  text: 'Créez en maintenant!',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],

      ),
    );
  }
}
