import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import './signinbuttons/sign_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './screens/donor_main.dart';
import './screens/receiver_home_screen.dart';
//import './error.dart';

class SignIn extends StatefulWidget {
  static const routeName = 'SignIN';
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late bool isDonor;
  final _auth = FirebaseAuth.instance;
  bool _showPwd = true;
  final pwd = TextEditingController();
  late bool hasUppercase;
  late bool hasDigits;
  late bool hasLowercase;
  late bool hasSpecialCharacters;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var _userEmail = '';
  var _userPasswrod = '';

  void password() {
    setState(() {
      _showPwd = !_showPwd;
    });
  }

  void validation() {
    hasUppercase = (pwd.text).contains(new RegExp(r'[A-Z]'));
    hasDigits = (pwd.text).contains(new RegExp(r'[0-9]'));
    hasLowercase = (pwd.text).contains(new RegExp(r'[a-z]'));
    hasSpecialCharacters =
        (pwd.text).contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (hasDigits & hasUppercase & hasLowercase & hasSpecialCharacters) {
      return;
    }
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

  void save() async {

    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    final authResult;
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();
    if (isValid != null) {
      _formKey.currentState?.save();
      try {
        setState(() {
          isLoading = true;
        });
        authResult = await _auth.signInWithEmailAndPassword(
            email: _userEmail.trim(), password: _userPasswrod.trim());
        var doc1 = Firestore
            .collection('users')
            .doc(authResult.user.uid);
        await doc1.get().then((value) {
          isDonor = value['Donor'];
        });
        print(isDonor);
        if (isDonor) {
          Navigator.of(context).pushReplacementNamed(DonorMain.routeName);
        } else {
          Navigator.of(context)
              .pushReplacementNamed(ReceiverHomeScreen.routeName);
        }
      } on PlatformException catch (err) {
        var message = 'An error occurred, please check your credentials!';
        if (err.message != null) {
          message = err.message!;
        }
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                  title: Text("Oops something went wrong"),
                  content: Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Column(children: <Widget>[
                        Text(
                          err.message == null
                              ? "sorry for incovinience"
                              : message,
                          style: TextStyle(fontSize: 15),
                        ),
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
      } catch (err) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                  title: Text("Oops something went wrong"),
                  content: Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Column(children: <Widget>[
                        Text(
                          "sorry for incovinience",
                          style: TextStyle(fontSize: 15),
                        ),
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
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                    Center(
                        child: Text('Login to your account',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18))),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.09,
                    ),
                    TextFormField(
                      initialValue: null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
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
                        _userEmail = value;
                        FocusScope.of(context).unfocus();
                      },
                      onSaved: (value) {
                        _userEmail = value!.trim();
                      },
                    ),
                    TextFormField(
                      initialValue: null,
                      controller: pwd,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock,color: Colors.black,),
                          suffixIcon: IconButton(
                            icon: _showPwd
                                ? Icon(Icons.visibility_off,color: Colors.black,)
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
                        FocusScope.of(context).unfocus();

                        _userPasswrod = value.trim();
                      },
                      onSaved: (value) {
                        _userPasswrod = value!;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(),

                        TextButton(onPressed: () {

                            _handleForgetPassword(context);
                          },
                              child: Text("Forget Password?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black, ),)),

                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    isLoading
                        ? CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    save();
                                  },
                                  child: Column(
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text('Log In',
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
                    Container(
                      // width:MediaQuery.of(context).size.width*0.35,

                      decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black),

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black,),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => SignUp()));
                        },
                        child: Column(
                          children: <Widget>[
                            Text('New user?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                            SizedBox(width: 5),
                            Container(
                              child: Text(
                                'Create a new account.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SignInButtons(),
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

  void _handleForgetPassword(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      Navigator.pop(context); // Close the dialog
                      _showSuccessDialog(context);
                    } catch (e) {
                      _showErrorDialog(context, e.toString());
                    }
                  } else {
                    _showErrorDialog(context, 'Please enter your email.');
                  }
                },
                child: Text('Send Reset Link'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Password reset link sent successfully. Check your email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
