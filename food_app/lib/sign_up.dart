import 'package:flutter/material.dart';
//import 'package:flutter_signin_button/flutter_signin_button.dart';
//import 'package:flutter_signin_button/button_view.dart';
import './tcpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}
enum UserType { Restaurant, Caterer, Individual }

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  bool _showPwd = true;
  final pwd = TextEditingController();
  final cnfrmpwd = TextEditingController();
  final phone =  TextEditingController();
  final _codeController =  TextEditingController();
  late bool hasUppercase;
  late bool hasDigits;
 late bool hasLowercase;
 late  bool hasSpecialCharacters;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var _userName = '';
  var _userEmail = '';
  var _userPasswrod = '';
  var _phone = '';
  late bool isDonor;
  bool isPhone = false;
  int count = 0;
  bool isResto = false;
  bool isCaterer = false;
  bool isIndividual = false;
  //String restoAddress = '';
  String restoName = '';
  //String catererAddress = '';
  String catererName = '';
  String indiName = '';
  bool right = false;
  bool _showCnfrmPwd = true;
  UserType? userType;
  FocusNode myFocusNode = FocusNode();
  String? signUpMethod;

  // final   _auth=FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    myFocusNode.attach(context);
  }
  @override
  void dispose() {
    myFocusNode.dispose();
    // Dispose other focus nodes if you have them
    super.dispose();
  }
  void password() {
    setState(() {
      _showPwd = !_showPwd;
    });
  }

  void passwordC() {
    setState(() {
      _showCnfrmPwd = !_showCnfrmPwd;
    });
  }

  void validation() {
    hasUppercase = (pwd.text).contains(new RegExp(r'[A-Z]'));
    hasDigits = (pwd.text).contains(new RegExp(r'[0-9]'));
    hasLowercase = (pwd.text).contains(new RegExp(r'[a-z]'));
    hasSpecialCharacters =
        (pwd.text).contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (hasDigits & hasUppercase & hasLowercase & hasSpecialCharacters) {
      setState(() {
        right = true;
      });

      return null;
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              elevation: 10,
              content: FittedBox(
                  child: Column(
                children: <Widget>[
                  Text('  Passwords must have :',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('   1. Atleast one Uppercase letter ',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Text('    2. Atleast one Lowercase letter ',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Text('    3. Atleast one Special character',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Text('    4. Atleast one number from 0-9!',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              )),
            );
          });
    }
  }
  void signUpAndSaveWithPhoneNumber() async {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    UserCredential? result; // Initialize with nullable type
    if (phone.text.toString() == null || phone.text.isEmpty) {
      // Handle empty or null phone number
      print("Error: Phone number is empty or null");
      return;
    }
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone.text.toString(),
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();

          result = await _auth.signInWithCredential(credential);

          User? user = result?.user; // Check for nullability

          if (user != null) {
            // Handle successful sign-in
          } else {
            print("Error");
          }
        },
        verificationFailed: (final exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Give the code?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text("Confirm"),
                    onPressed: () async {
                      final code = _codeController.text.trim();
                      AuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: code,
                      );

                      result = await _auth.signInWithCredential(credential);

                      User? user = result?.user; // Check for nullability
                      signUpMethod = 'phone';
                      if (user != null) {
                        if (result != null && (isDonor) && (isPhone == true)) {
                          if (userType == UserType.Restaurant) {
                            await Firestore
                                .collection('donors')
                                .doc(result!.user?.uid)
                                .set({
                              'phone': phone.text.toString(),
                              'type of donor': 'Restaurant',
                              'address': " ",
                              'reportCount': 0,
                            });
                          } else if (userType == UserType.Caterer) {
                            await Firestore
                                .collection('donors')
                                .doc(result!.user?.uid)
                                .set({
                              'phone': phone.text.toString(),
                              'type of donor': 'Caterer',
                              'address': " ",
                              'reportCount': 0,
                              'SignUpMethod': signUpMethod
                            });
                          } else if (userType == UserType.Individual) {
                            await Firestore
                                .collection('donors')
                                .doc(result!.user?.uid)
                                .set({
                              'phone': phone.text.toString(),
                              'type of donor': 'Individual',
                              'address': " ",
                              'reportCount': 0,
                            });
                          }
                        }
                        if (result != null && (isDonor == false) && (isPhone == true)) {
                          await Firestore
                              .collection('receiver')
                              .doc(result!.user?.uid)
                              .set({
                            'phone': phone.text.toString(),
                            'username': _userName.trim(),
                          });
                        }
                        await Firestore
                            .collection('users')
                            .doc(result!.user?.uid)
                            .set({'Donor': isDonor,
                          'SignUpMethod': signUpMethod

                        });
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => TCpage(isDonor)));

                        // Navigator.of(context).pushReplacement(
                        //     MaterialPageRoute(builder: (ctx) => TCpage(isDonor)));
                      } else {
                        print("Error");
                      }
                    },
                  )
                ],
              );
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout
        },
      );


    } catch (e) {
      print("Error during phone number verification: $e");
    }
  }




  void saveAll() async {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    final authResult;
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          isLoading = true;
        });
        authResult = await _auth.createUserWithEmailAndPassword(
            email: _userEmail, password: _userPasswrod);


        signUpMethod = 'email';

        if (isDonor) {
          if (userType == UserType.Restaurant) {
            await Firestore
                .collection('donors')
                .doc(authResult.user.uid)
                .set({
              'username': _userName.trim(),
              'email': _userEmail.trim(),
              'type of donor': 'Restaurant',
              'address': " ",
              'reportCount': 0,
            });
          }
          if (userType == UserType.Caterer){
            await Firestore
                .collection('donors')
                .doc(authResult.user.uid)
                .set({
              'username': _userName.trim(),
              'email': _userEmail.trim(),
              'type of donor': 'Caterer',
              'address': " ",
              'reportCount': 0,
            });
          }
          if (userType == UserType.Individual) {
            await Firestore
                .collection('donors')
                .doc(authResult.user.uid)
                .set({
              'username': _userName.trim(),
              'email': _userEmail.trim(),
              'type of donor': 'Individual',
              'address': " ",
              'reportCount': 0,
            });
          }
        } else {
          await Firestore
              .collection('receiver')
              .doc(authResult.user.uid)
              .set({
            'username': _userName.trim(),
            'email': _userEmail.trim(),
          });
        }
        await Firestore
            .collection('users')
            .doc(authResult.user.uid)
            .set({'Donor': isDonor, 'SignUpMethod': signUpMethod});
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => TCpage(isDonor)));
      } on PlatformException catch (err) {
        var message = 'An error occurred, pelase check your credentials!';

        if (err.message != null) {
          message = err.message!;
        }
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                  title: Text("Oops something went wrong"),
                  content: FittedBox(
                      child: Column(children: <Widget>[
                    Text(err.message == null
                        ? "sorry for incovinience"
                        : message),
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ])));
            });

        setState(() {
          isLoading = false;
        });
        print(err.message);
      } catch (err) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                  title: Text("Oops something went wrong"),
                  content: FittedBox(
                      child: Column(children: <Widget>[
                    Text("sorry for incovinience"),
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ])));
            });

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
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
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    if (isPhone== false)
                    TextFormField(
                      initialValue: null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
                           prefixIcon: Icon(Icons.email,color: Colors.black,),
                         
                          ),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid Email.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        _userEmail = value;
                        FocusScope.of(context).unfocus();
                      },
                      onSaved: (value) {
                        _userEmail = value!;
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    if (isPhone== true)
                    TextFormField(
                      initialValue: null,
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone,color: Colors.black,),

                      ),
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Input Phone Number';
                        }
                        if(!value.contains('+92')){
                          return 'Country Code is Missing';
                        }
                        if(value.length <11 ){
                          return 'Invalid Phone Number';
                        }

                        return null;
                      },

                      onFieldSubmitted: (value) {
                        phone.text = value;
                        FocusScope.of(context).unfocus();
                      },
                      onSaved: (value) {
                        phone.text = value!;
                        FocusScope.of(context).unfocus();
                      },

                    ),
                    if (isPhone== false)
                    TextFormField(
                      initialValue: null,
                      controller: pwd,
                      
                      decoration: InputDecoration(
                          labelText: 'Password',

                          //labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                          //fillColor: Colors.black,
                           prefixIcon: Icon(Icons.lock,color: Colors.black,),
                          suffixIcon: IconButton(
                            icon: _showPwd
                                ? Icon(Icons.visibility_off,
                                    color: Colors.black)
                                : Icon(Icons.visibility, color: Colors.black),
                            onPressed: () => password(),
                          )),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      obscureText: _showPwd,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        // validation();
                        _userPasswrod = value;
                        FocusScope.of(context).unfocus();
                      },
                      onSaved: (value) {
                        // validation();
                        _userPasswrod = value!;
                      },
                    ),
                    if (isPhone== false)
                    TextFormField(
                      initialValue: null,
                      controller: cnfrmpwd,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock,color: Colors.black,),
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: _showCnfrmPwd
                                ? Icon(Icons.visibility_off,
                                    color: Colors.black)
                                : Icon(Icons.visibility, color: Colors.black),
                            onPressed: () => passwordC(),
                          )),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      obscureText: _showCnfrmPwd,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (value != pwd.text) {
                          return 'Passwrods do not match!';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      onSaved: (value) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    count == 1
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'What are you?',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              RadioListTile(
                                title: Text("Restaurant",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                value: UserType.Restaurant,
                                onChanged: (newValue) {
                                  setState(() {
                                    userType = newValue as UserType;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .leading, groupValue: userType, //  <-- leading Checkbox
                              ),
                              RadioListTile(
                                title: Text("Caterer",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                value: UserType.Caterer,
                                onChanged: (newValue) {
                                  setState(() {
                                    userType = newValue as UserType;
                                  });
                                },
                                groupValue: userType,
                                controlAffinity: ListTileControlAffinity
                                    .leading, //  <-- leading Checkbox
                              ),
                              RadioListTile(
                                title: Text('Individual',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                value: UserType.Individual,
                                onChanged: (newValue) {
                                  setState(() {
                                    userType = newValue as UserType;
                                  });
                                },
                                groupValue: userType,
                                controlAffinity: ListTileControlAffinity
                                    .leading, //  <-- leading Checkbox
                              ),
                           (userType == UserType.Restaurant)
                                  ? TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Restaurant name',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      onFieldSubmitted: (value) {
                                        _userName = value;
                                        FocusScope.of(context).unfocus();
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'enter a vaild name';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _userName = value!;
                                      },
                                    )
                                  : Text(''),
                              (userType == UserType.Individual)
                                  ? TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Your name',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      onFieldSubmitted: (value) {
                                        _userName = value;
                                        FocusScope.of(context).unfocus();
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return ' Enter a valid name';
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _userName = value!;
                                      },
                                    )
                                  : Text(''),
                              (userType == UserType.Caterer)
                                  ? TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Caterer name',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      onFieldSubmitted: (value) {
                                        _userName = value;
                                        FocusScope.of(context).unfocus();
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return ' Enter a valid name';
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _userName = value!;
                                      },
                                    )
                                  : Text(''),
                            ],
                          )
                        : Text(''),
                    count == -1
                        ? TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Your name',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            onFieldSubmitted: (value) {
                              _userName = value;
                              FocusScope.of(context).unfocus();
                            },
                            validator: (value) {
                              if (value!.isEmpty) return ' Enter a valid name';
                              return null;
                            },
                            onSaved: (value) {
                              _userName = value!;
                            },
                          )
                        : Text(''),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        if (count == 0)
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black,),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _formKey.currentState!.validate();

                                setState(() {
                                  isDonor = false;
                                  count = -1;
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  Text('Sign Up',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                  Text(
                                    'Start Recieving..',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 10,),
                        if (count == 0)
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black,),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _formKey.currentState!.validate();
                                setState(() {

                                  isDonor = true;
                                  count = 1;
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  Text('Sign Up',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                  Text(
                                    'Start Donating..',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 10,),
                        if (count == 0)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isPhone=true;
                                isDonor = false;
                                count = -1;
                              });
                            },
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text('Sign Up with Phone Number',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                                SizedBox(height: 3),
                                Text('Start Receiving',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
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
                        if (count == 0)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isPhone=true;
                                isDonor = true;
                                count = 1;
                              });
                            },
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text('Sign Up with Phone Number',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                                SizedBox(height: 3),
                                Text('Start Donating',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
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
                        isLoading
                            ? Container(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.black,
                                ),
                                alignment: Alignment.center,
                              )
                            : count != 0
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black,),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        if(isPhone==false){
                                          _formKey.currentState!.validate()
                                              ? validation()
                                              : print('');

                                          right ? saveAll() : print('');
                                        }else{
                                          signUpAndSaveWithPhoneNumber();
                                        }

                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Text('Sign Up',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white)),
                                          /* Text(
                                            'Start helping..',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          )*/
                                        ],
                                      ),
                                    ),
                                  )
                                : Text("")
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*SizedBox(height:20),

                              
                               Container
                              (
                                width:MediaQuery.of(context).size.width*0.35 ,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.black),
                               // padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.25),
                                child: isLoading?
                                Center(child: CircularProgressIndicator(),)
                                :FlatButton
                                (
                                  onPressed: () 
                                  {
                                    FocusScope.of(context).unfocus();
                                    validation();
                                    
                                 right? saveAll():print('');
                                  },
                                  child: Column
                                  (
                                    children: <Widget>
                                    [
                                      Text
                                      (
                                        'Sign Up',
                                        textAlign: TextAlign.center,
                                        style:TextStyle(fontSize:20,fontWeight: FontWeight.w500,color:Colors.white)
                                      ),
                                      Text
                                      (
                                        'Start helping..',
                                        textAlign: TextAlign.center,
                                        style:TextStyle(fontSize: 12,color:Colors.white,),
                                      )  
                                    ],
                                  ),
                                ),
                              ),

                     

                           SizedBox
                          (
                            height: 10,
                          ),


                         /* Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>
                            [
                              Container
                              (
                                 child: Text
                                 (
                                  'Try Other Options',
                                   style:TextStyle(color:Colors.black,fontSize: 16,fontWeight: FontWeight.bold), 
                                 ),
                              ),

                             SignInButton
                             (
                               Buttons.AppleDark,
                               mini:true,
                               onPressed: () {},
                             ), 

                             SignInButton
                             (
                               Buttons.Facebook,
                               mini:true,
                               onPressed: () {},
                             ),

                             SignInButton
                             (
                               
                               Buttons.Twitter,
                               mini: true,
                               onPressed: () {},
                             ), 
                            ],
                          ), */
                      ],
            ),
                        ),
                   // ),
                ),
              ),
     // ),
        
        ),
          ),
    );
      
  
  }
}*/
