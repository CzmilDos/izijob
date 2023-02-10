import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/persistence/persistance.dart';
import 'package:linkedin_clone/services/global_methods.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';
import 'package:uuid/uuid.dart';


class UploadJob extends StatefulWidget {
  const UploadJob({Key? key}) : super(key: key);

  @override
  _UploadJobState createState() => _UploadJobState();
}

class _UploadJobState extends State<UploadJob> {

  TextEditingController _jobCategoryController = TextEditingController(text: 'Sélectionner une catégorie');
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _jobDescriptionController = TextEditingController();
  TextEditingController _deadLineDateController = TextEditingController(text: 'Date limite');

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadLineDateTimestamp;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _deadLineDateController.dispose();

  }

  void _uploadJob() async {
      final jobId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if(isValid){
      if(_deadLineDateController.text == 'Donnez la date limite pour le job'
        || _jobCategoryController.text == 'Chosissez une catégorie pour l\'emploi'){
        GlobalMethod.showErrorDialog(
          error: 'Veuillez remplir tous les champs', ctx: context
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try{
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId': jobId,
          'uploadedBy': _uid,
          'email': user.email,
          'jobTitle': _jobTitleController.text,
          'jobDescription': _jobDescriptionController.text,
          'deadLineDate': _deadLineDateController.text,
          'deadLineDateTimeStamp': deadLineDateTimestamp,
          'jobCategory': _jobCategoryController.text,
          'jobComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
          'isValidated': false
        });
        await Fluttertoast.showToast(
            msg: 'L\'offre est envoyé avec succès, elle sera validé par l\'admiinistrateur',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.blue[200],
            fontSize: 18.0
        );
        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = 'Sélectionner une catégorie';
          _deadLineDateController.text = 'Date limite';
        });
      }catch(error) {} finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
            'Veuillez remplir tous les champs',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: AppBottomNavigationBar(indexNum: 2,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Card(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textTitles(label: "Catégorie :"),
                          _textFormFields(
                              valueKey: 'jobCategory',
                              controller: _jobCategoryController,
                              enabled: false,
                              fct: (){
                                _showJobCategoryDialog(size: size);
                              },
                              maxLength: 100
                          ),
                          _textTitles(label: "Titre :"),
                          _textFormFields(
                              valueKey: 'jobTitle',
                              controller: _jobTitleController,
                              enabled: true,
                              fct: (){},
                              maxLength: 100,
                          ),
                          _textTitles(label: "Description :"),
                          _textFormFields(
                              valueKey: 'jobDescription',
                              controller: _jobDescriptionController,
                              enabled: true,
                              fct: (){},
                              maxLength: 200,
                          ),
                          _textTitles(label: "Date limite :"),
                          _textFormFields(
                              valueKey: 'jobDeadLine',
                              controller: _deadLineDateController,
                              enabled: false,
                              fct: (){
                                _pickDateDialog();
                              },
                              maxLength: 100
                          ),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: _isLoading ? CircularProgressIndicator()
                          : MaterialButton(
                            onPressed: _uploadJob,
                            color: Colors.blue,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Poster',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              )
                            ],
                          ),
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

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength
  }) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Veuillez renseigner ce champ...!";
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          maxLines: valueKey == 'jobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xff5dade2),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  _showJobCategoryDialog({required Size size}){
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          content: Container(
            width: size.width * 0.9,
            child: ListView.builder(shrinkWrap: true,
              itemCount: Persistance.jobCategoryList.length,
              itemBuilder: (ctxx, index){
                return InkWell(
                  onTap: (){
                    setState(() {
                      _jobCategoryController.text = Persistance.jobCategoryList[index];
                    });
                    Navigator.pop(context);
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
              }
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: Text('Annuler', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ],
        );
      }
    );
  }

  void _pickDateDialog() async{
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: 0),
      ),
      lastDate: DateTime(2100),
    );

    if(picked != null){
      setState(() {
        _deadLineDateController.text = '${picked!.day}-${picked!.month}-${picked!.year}';
        deadLineDateTimestamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
      });
    }
  }

  Widget _textTitles({required String label}){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
