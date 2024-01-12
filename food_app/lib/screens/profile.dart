import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './donor_main.dart';

enum UserType { Restaurant, Caterer, Individual }

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  static const routeName = '/profile-screen';
  bool _showPwd = true;
  final pwd = TextEditingController();
  final regemail = TextEditingController();
  final category = TextEditingController();
  final addr = TextEditingController();
  final phone = TextEditingController();
  final userName =  TextEditingController();
  late bool hasUppercase;
  late bool hasDigits;
  late bool hasLowercase;
  late  bool hasSpecialCharacters;
  late  String email;
  late String donorType;
  late String address;
  late String PhoneNumber;
  late String oldEmail;
  bool right = false;
  var _userPasswrod = '';

  final _formKey = GlobalKey<FormState>();
  String? selectedDropdownValue;
  bool? isDonor;
  String? SignUpMethod;
  FirebaseFirestore Firestore = FirebaseFirestore.instance;
  static const List<Set<String>> Categories = [
    {"Restaurant"},
    {'Caterer'},
    {'Individual'}
  ];

  UserType? userType;


  @override
  void initState() {
    super.initState();
    fetchEamilaAndCategory();
  }


  Future<void> fetchEamilaAndCategory () async{
    CollectionReference users = Firestore.collection('users');
    CollectionReference donors = Firestore.collection('donors');
    CollectionReference receivers = FirebaseFirestore.instance.collection('receiver');
    User? user = FirebaseAuth.instance.currentUser;
    final userID =  user?.uid;
    DocumentSnapshot documentSnapshotForDonor = await users.doc(userID).get();
    DocumentSnapshot documentSnapshot =  await donors.doc(userID).get();
    DocumentSnapshot documentSnapshotForReceiver = await receivers.doc(userID).get();

    if (documentSnapshotForDonor.exists && documentSnapshotForDonor.data() != null) {
      setState(() {
        isDonor = documentSnapshotForDonor['Donor'];
        SignUpMethod = documentSnapshotForDonor['SignUpMethod'];
        print(SignUpMethod);
        // print('isDonor: ');
         print(isDonor);


      });



      if(isDonor==true && SignUpMethod=='email'){
        if(documentSnapshot.exists && documentSnapshot.data() != null){
          setState(() {
            email = documentSnapshot['email'];
            donorType = documentSnapshot['type of donor'];
            address = documentSnapshot['address'];

            regemail.text = email;
            category.text = donorType;
            addr.text = address;
            oldEmail = email;
            // category.value = documentSnapshot['type of donor'];
            // addr.value = documentSnapshot['address'];
            // print(email);
            // print(donorType);

          });
        }
      } else if(isDonor==false && SignUpMethod=='email'){
        if(documentSnapshotForReceiver.exists && documentSnapshotForReceiver.data() != null ){
          setState(() {
            email = documentSnapshotForReceiver['email'];
            regemail.text = email;
            oldEmail = email;
          });
        }

      }else if(isDonor==true && SignUpMethod=='phone'){
        if(documentSnapshot.exists && documentSnapshot.data() != null){
          setState(() {
            PhoneNumber = documentSnapshot['phone'];
            donorType = documentSnapshot['type of donor'];
            address = documentSnapshot['address'];

            phone.text = PhoneNumber;
            category.text = donorType;
            addr.text = address;
            // category.value = documentSnapshot['type of donor'];
            // addr.value = documentSnapshot['address'];
            // print(email);
            // print(donorType);

          });
        }
      }else if(isDonor==false && SignUpMethod=='phone'){
        if(documentSnapshotForReceiver.exists && documentSnapshotForReceiver.data() != null ){
          setState(() {
            PhoneNumber = documentSnapshotForReceiver['phone'];
            phone.text = PhoneNumber;
          });
        }

      }



    } else {
      // Handle the case where the document or email field doesn't exist
      setState(() {
       isDonor= false;
      });
    }
  }








  void updateProfile() async{
    CollectionReference donors = FirebaseFirestore.instance.collection('donors');
    CollectionReference receivers = FirebaseFirestore.instance.collection('receiver');

    User? user = FirebaseAuth.instance.currentUser;
    final userID = user?.uid;

    final isValid = _formKey.currentState?.validate();
    String newemail =  regemail.text;
    String donorType =  category.text;
    String address =  addr.text;
    String phoneNo = phone.text;
    String username = userName.text;
    if(isValid !=null){
      _formKey.currentState!.save();
      try{


        if(isDonor==true && SignUpMethod=='email'){
          await donors.doc(userID).set({
            'email': newemail,
            'type of donor': donorType,
            'address': address,
          });
        }else if (isDonor ==false && SignUpMethod=='email'){
          await receivers.doc(userID).set({
            'email': newemail,
            'username': username,

          });
        }else if(isDonor==true && SignUpMethod=='phone'){
          await donors.doc(userID).set({
            'phone': phoneNo,
            'type of donor': donorType,
            'address': address,
          });
        }else if(isDonor==false && SignUpMethod=='phone'){
          await receivers.doc(userID).set({
            'phone': phoneNo,
            'username': username,

          });
        }


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile data updated successfully!.'),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );


        print('Profile data updated successfully!');


      }catch(e){

        print('Error updating profile data: $e');

      }
    }




  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: (){
            Navigator.of(context).pushNamed(DonorMain.routeName);
          },
        ),
        title: Text('Profile', style: TextStyle(color: Colors.white),),
      ),
      body:
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/auth.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(25),
          color: Colors.white70,
          child: SingleChildScrollView(
            // child: Expanded
            //(

            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                  ),
                  Center(
                      child: Text('Profile',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18))),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                 (SignUpMethod=='email') ?
                  TextFormField(
                    controller: regemail,
                    enabled: false,
                    initialValue: null,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Registered Email',
                        prefixIcon: Icon(Icons.email, color: Colors.black)),
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      // _userEmail = value;
                      FocusScope.of(context).unfocus();
                    },
                    onSaved: (value) {
                      // _userEmail = value!.trim();
                    },
                  ):
                 TextFormField(
                   controller: phone,
                   enabled: false,
                   initialValue: null,
                   keyboardType: TextInputType.emailAddress,
                   decoration: InputDecoration(
                       labelText: 'Phone Number',
                       prefixIcon: Icon(Icons.email, color: Colors.black)),
                   style:
                   TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                   textInputAction: TextInputAction.next,
                   validator: (value) {
                     if (value!.isEmpty || value.length < 11) {
                       return 'Please provide a  valid value.';
                     }
                     return null;
                   },
                   onFieldSubmitted: (value) {
                     FocusScope.of(context).unfocus();
                     // _userEmail = value;
                     FocusScope.of(context).unfocus();
                   },
                   onSaved: (value) {
                     // _userEmail = value!.trim();
                   },
                 )


                  ,
                  SizedBox(
                    height: 10,
                  ),

                  if (isDonor==true)
                  TextFormField(
                    controller: category,
                    initialValue: null,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined, color: Colors.black),



                    ),
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      // _userEmail = value;
                      FocusScope.of(context).unfocus();
                    },
                    onSaved: (value) {
                      // _userEmail = value!.trim();
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (isDonor==true)
                  TextFormField(
                    controller: addr,
                    initialValue: null,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                        labelText: 'Pick-up Address',
                        prefixIcon: Icon(Icons.place, color: Colors.black)),
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      // _userEmail = value;
                      FocusScope.of(context).unfocus();
                    },
                    onSaved: (value) {
                      // _userEmail = value!.trim();
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if( isDonor==false)
                    TextFormField(
                      controller: userName,
                      initialValue: null,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                          labelText: 'UserName',
                          prefixIcon: Icon(Icons.account_box, color: Colors.black)),
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                        // _userEmail = value;
                        FocusScope.of(context).unfocus();
                      },
                      onSaved: (value) {
                        // _userEmail = value!.trim();
                      },
                    ),




                  SizedBox(
                    height: 30,
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                              _formKey.currentState!.validate()
                                  ? updateProfile()
                                  : print('');


                            // save();
                          },
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text('Update Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: 3),
                              /* Container(

                                  child:
                                     Text(
                                        'Continue Helping..',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                )*/
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),


                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // SignInButtons(),
                ],
              ),
            ),
            // ),
          ),
        ),

      ),
      // Column(
      //   children: <Widget>[
      //     Text('Name: '),
      //     SizedBox(height: 20,),
      //     Text('Registered Email: '),
      //     SizedBox(height: 20,),
      //     Text('Category: '),
      //     SizedBox(height: 20,),
      //     Text('Pick Up Address: '),
      //     SizedBox(height: 20,),
      //   ],
      // ),
    );
  }
}