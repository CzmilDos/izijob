import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkedin_clone/services/global_methods.dart';
import 'package:linkedin_clone/widgets/wave_widget.dart';

import '../user_state.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  late TextEditingController _fullNameController = TextEditingController(text: '');
  late TextEditingController _emailTextController = TextEditingController(text: '');
  late TextEditingController _passTextController = TextEditingController(text: '');
  late TextEditingController _phoneNumberController = TextEditingController(text: '');
  late TextEditingController _locationController = TextEditingController(text: '');

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passFocusNode = FocusNode();
  FocusNode _positionFocusNode = FocusNode();
  FocusNode _phoneNumberFocusNode = FocusNode();
  bool _obscureText = true;
  final _signUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? imageUrl;

  @override
  void dispose() {

    _fullNameController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _positionFocusNode.dispose();
    _phoneNumberFocusNode.dispose();

    super.dispose();
  }

  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if (isValid) {
      if (imageFile == null) {
        GlobalMethod.showErrorDialog(
            error: 'Veuillez choisir une image de profil', ctx: context
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim()
        );
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance.ref().child('userImages').child(
            _uid + '.jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'userImage': imageUrl,
          'phoneNumber': _phoneNumberController.text,
          'location': _locationController.text,
          'creationDate': Timestamp.now(),
          'role': 'user',
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserState()));
      }catch(error){
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(
            error: error.toString(),
            ctx: context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final String hintText1 = 'Nom complet / Nom de la société';
    final String hintText2 = 'Email';
    final String hintText3 = 'Mot de passe';
    final String hintText4 = 'Numéro de téléphone';
    final String hintText5 = 'Adresse';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          children: <Widget>[
            Container(
              height: size.height - 200,
              color: Colors.blue ,
            ),

            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
              top:keyboardOpen? -size.height / 3.7 : 0.0,
              child: WaveWidget(
                size: size,
                yOffset: size.height / 2.7,
                color: Colors.white
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 35, right: 35, top: 120),
                child: ListView(
                  children: [
                    Form(
                      key: _signUpFormKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              _showImageDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.height * 0.13,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? Icon(Icons.camera_enhance, color: Colors.white, size: 30,)
                                      : Image.file(imageFile!, fit: BoxFit.fill ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocusNode),
                            keyboardType: TextInputType.name,
                            controller: _fullNameController,
                            validator: (value){
                              if(value!.isEmpty){
                                return "Veuillez remplir ce champ !";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(
                                color: Colors.blueGrey),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.account_circle_outlined,
                                color: Colors.blue,
                              ),

                              labelText: hintText1,
                              labelStyle: TextStyle(color: Colors.black54, fontSize: 18),
                              hintStyle: TextStyle(color: Colors.black87, fontSize: 18),
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                            focusNode: _emailFocusNode,
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
                                color: Colors.blueGrey,
                            ),
                            decoration: InputDecoration(

                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.blue,
                              ),

                              labelText: hintText2,
                              labelStyle: TextStyle(color: Colors.black54, fontSize: 18),
                              hintStyle: TextStyle(color: Colors.black87, fontSize: 18),
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneNumberFocusNode),
                            focusNode: _passFocusNode,
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passTextController,
                            validator: (value){
                              if(value!.isEmpty || value.length < 7){
                                return "Au moins sept (07) caractères !";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.blueGrey),
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
                              labelStyle: TextStyle(color: Colors.black54, fontSize: 18),
                              hintStyle: TextStyle(color: Colors.black87, fontSize: 18),
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_positionFocusNode),
                            focusNode: _phoneNumberFocusNode,
                            keyboardType: TextInputType.phone,
                            controller: _phoneNumberController,
                            validator: (value){
                              if(value!.isEmpty){
                                return "Veuillez remplir ce champ !";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.blueGrey),
                            decoration: InputDecoration(

                              prefixIcon: Icon(
                                Icons.contact_phone_outlined,
                                color: Colors.blue,
                              ),

                              labelText: hintText4,
                              labelStyle: TextStyle(color: Colors.black54, fontSize: 18),
                              hintStyle: TextStyle(color: Colors.black87, fontSize: 18),
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_positionFocusNode),
                            focusNode: _positionFocusNode,
                            keyboardType: TextInputType.text,
                            controller: _locationController,
                            validator: (value){
                              if(value!.isEmpty){
                                return "Veuillez remplir ce champ !";
                              }else{
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.blueGrey),
                            decoration: InputDecoration(

                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: Colors.blue,
                              ),

                              labelText: hintText5,
                              labelStyle: TextStyle(color: Colors.black54, fontSize: 18),
                              hintStyle: TextStyle(color: Colors.black87, fontSize: 18),
                              filled: true,
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _isLoading
                          ? Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(),
                            ),
                          ) : MaterialButton(
                            onPressed: _submitFormOnSignUp,
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
                                    'Valider',
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
                            height: 20,
                          ),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Vous avez déja un compte?',
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
                                    ..onTap = () => Navigator.canPop(context)
                                    ? Navigator.pop(context)
                                    : null,
                                    text: 'Se connecter',
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

  void _showImageDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Veuillez choisir une option !'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    _getFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      Text(
                        'Appareil photo',
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    _getFromGallery();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      Text(
                        'Gallerie',
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _getFromGallery() async {
    PickedFile? pickedfile = (await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 1080,
        maxWidth: 1080
    ));
    _cropImage(pickedfile!.path);
    Navigator.pop(context);
  }


  void _getFromCamera() async{
    PickedFile? pickedfile = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxHeight: 1080,
        maxWidth: 1080,
    );
    _cropImage(pickedfile!.path);
    Navigator.pop(context);

  }

  void _cropImage(filePath) async {
    File? croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        maxHeight: 1080,
        maxWidth: 1080
    );
    if(croppedImage != null){
      setState(() {
        imageFile = croppedImage;
      });
    }

  }

}

