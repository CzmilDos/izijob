import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/widgets/all_companies_widget.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';

class WorkersScreen extends StatefulWidget {
  @override
  _WorkersScreenState createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {

  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Rechercher un employeur...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: 18),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions(){
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: (){
          _clearSearchQuery();
        },
      ),
    ];
  }

  void updateSearchQuery(String newQuery){
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  void _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavigationBar(indexNum: 1,),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),
            );
          }else if (snapshot.connectionState == ConnectionState.active){
            if(snapshot.data!.docs.isNotEmpty){
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    return WorkersWidget(
                        userID: snapshot.data!.docs[index]['id'],
                        userName: snapshot.data!.docs[index]['name'],
                        userEmail: snapshot.data!.docs[index]['email'],
                        phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                        userImageUrl: snapshot.data!.docs[index]['userImage'],
                    );
                  }
              );
            }else{
              return Center(
                child: Text('Aucun utilisateur correspondant!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87
                ),),
              );
            }
          }
          return Center(
            child: Text('Une erreur s\'esst produite',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

          );
        }
      ),
    );
  }
}
