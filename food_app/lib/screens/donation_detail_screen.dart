import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_app/screens/timer.dart';
import './confirm_order_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import './confirm_order_screen.dart';
class DonationDetailScreen extends StatefulWidget {
  static const routeName = 'donation-detail-screen';

  @override
  _DonationDetailScreenState createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  Map userData = {};
  bool isLoading = false;
  var hasTimerStopped = false;
  FirebaseFirestore Firestore = FirebaseFirestore.instance;
  Future orderConfirm(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text('Are you sure?'),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () async {
                      try {
                        final user = await FirebaseAuth.instance.currentUser!;
                        var user11 = await Firestore
                            .collection('receiver')
                            .doc(user.uid)
                            .get();
                        String username1 = user11['username'];
                        await FirebaseFirestore.instance
                            .collection('receiver')
                            .doc(user.uid)
                            .collection('past orders')
                            .doc(userData['id'])
                            .set({
                          'username': userData['username'],
                          'address': userData['address'],
                          'typeofdonor': userData['typeofdonor'],
                          'isVeg': userData['isVeg'],
                          'range': userData['range'],
                          'foodDescription': userData['foodDescription'],
                          'donorName': userData['donorName'],
                          'contact': userData['contact'],
                          'email': userData['email'],
                          'date': userData['date'],
                          'time': DateTime.now(),
                          'finished': false,
                          'id': userData['id'],
                          'userId': userData['userId']
                        });
                        Navigator.of(context).pushNamed(
                            ConfirmOrderScreen.routeName,
                            arguments: {
                              'status': userData['status'],
                              'id': userData['id'],
                              'userId': userData['userId'],
                              'receiverId': user.uid
                            });

                        await Firestore
                            .collection('orders')
                            .doc(userData['id'])
                            .update({
                          'status': true,
                          'orderconfirmed': username1,
                        }).then((_) {
                          setState(() {
                            isLoading = false;
                          });
                        });
                      } on PlatformException catch (err) {
                        var message =
                            'An error occurred, pelase check your credentials!';

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
                                        ? "sorry for inconvinience"
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
                                    Text("sorry for inconvinience"),
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
                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(color: Colors.black),
                    )),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No', style: TextStyle(color: Colors.black)),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    userData = ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic> ;
    final rangeNumber = userData['range'].toString();
    DateTime time1 = userData['date'].toDate();

    var date2 = time1.difference(DateTime.now()).inSeconds;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_rounded, color: Colors.white,)),
        ),

        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: Container(
              color: userData['isConfirm'] ? Colors.grey : Colors.green,
              child: ElevatedButton(
                  onPressed: () {
                    if (userData['isConfirm']) {
                      return null;
                    }
                    orderConfirm(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 40,
                      ),
                      Text(
                        'CONFIRM',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ],
                  ))),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Container(
                color: Colors.black,
                child: ListTile(
                  title: Text(userData['donorName'],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  subtitle: Text(userData['typeofdonor'],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontStyle: FontStyle.italic)),
                ),
              ),
              //Divider(color: Colors.black,),
              Container(
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(userData['email'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          //fontStyle: FontStyle.italic
                        )),
                    SizedBox(
                      height: 2,
                    ),
                    Text(userData['contact'].toString(),
                        style: TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                          color: Colors.white,
                          fontSize: 20,
                          //fontStyle: FontStyle.italic
                        ))
                  ],
                ),
              ),
              Container(
                child: ListTile(
                  title: Text(
                    'Type:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Text(
                    userData['isVeg'] ? 'Vegetarian' : 'Non-Vegetarian',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Divider(
                thickness: 4,
              ),
              Container(
                child: ListTile(
                  title: Text('Range:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Text('Serves nearly $rangeNumber ',
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              Divider(
                thickness: 4,
              ),
              Container(
                child: ListTile(
                  title: Text('Food Description:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Text(userData['foodDescription'],
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              Divider(
                thickness: 4,
              ),
              Container(
                child: ListTile(
                  title: Text('Address:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle:
                      Text(userData['address'], style: TextStyle(fontSize: 20)),
                ),
              ),
              Divider(
                thickness: 4,
              ),
              // Container(
              //   // width: 60.0,
              //   //padding: EdgeInsets.only(top: 3.0, right: 4.0),
              //   child: ListTile(
              //     title: Text('Time until the donation expires:',
              //         style:
              //             TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              //     subtitle: Align(
              //       alignment: Alignment.bottomLeft,
              //       child: CountDownTimer(
              //         secondsRemaining: date2,
              //         whenTimeExpires: () {
              //           setState(() {
              //             hasTimerStopped = true;
              //           });
              //         },
              //         countDownStyle: TextStyle(
              //             color: Colors.green, fontSize: 150.0, height: 100), countDownFormatter:() {}, countDownTimerStyle: TextStyle(),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ));
  }
}
