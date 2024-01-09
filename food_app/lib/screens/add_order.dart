import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './tick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './donor_main.dart';
class AddOrder extends StatefulWidget {
  static const routeName = '/add-order';

  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  FirebaseFirestore Firestore =  FirebaseFirestore.instance;
  @override
  void initState() {
    void fetch() async {
      var user = await FirebaseAuth.instance.currentUser!;
      address = await Firestore
          .collection('donors')
          .doc(user.uid)
          .get();
      address1 = address['address'];
      addressIp = TextEditingController(text: address1);
    }

    fetch();

    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String address1;

  bool _autoValidate = false;
  final rangeIp = TextEditingController();

  final descripIp = TextEditingController();

  bool isVege = false;
  bool isNVeg = false;
  var description;
  var range;
  var address;
  var addressIp;
  final _addressFN = FocusNode();
  final _descriptionFN = FocusNode();
  final _contactFN = FocusNode();
  bool isLoading = false;
  var contact;
  var address2;
  late DateTime _day;
  late DateTime _time1;
  String _time = "Set Time";
  String _date = "Set Date";

  bool _checkboxValid() {
    if (isVege == isNVeg) {
      return false;
    }
    return true;
  }

  bool _validateInputs() {
    if (!_checkboxValid()) {
      return false;
    }
    if (_formKey.currentState!.validate()) {
      //    If all data are correct then save data to out variables
      _formKey.currentState?.save();
      return true;
    } else {
      //    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: currentDate.add(Duration(hours: 24)),
    );

    if (picked != null && picked != currentDate) {
      print('confirm $picked');
      _date = '${picked.day} - ${picked.month} - ${picked.year}';
      setState(() {
        DateTime day5;
        if (picked.hour != 0 ||
            picked.minute != 0 ||
            picked.second != 0 ||
            picked.microsecond != 0 ||
            picked.millisecond != 0) {
          day5 = picked.subtract(Duration(
            seconds: picked.second,
            hours: picked.hour,
            minutes: picked.minute,
            microseconds: picked.microsecond,
            milliseconds: picked.millisecond,
          ));
        } else {
          day5 = picked;
        }
        if (picked.subtract(Duration(hours: 24)).isAfter(DateTime.now())) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                elevation: 10,
                content: FittedBox(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Oops something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Pickup time should be within 24 hours from now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          print(day5);
          _day = day5;
        }
      });
    }
  }
  Future<void> pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _time = pickedTime.format(context);
      });
    }
  }
  void submit() async {
    print('onsubmit');
    print(_time);
    print(_day);
    print('-----');

    if (_time.isEmpty || _day == null) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Oops something went wrong"),
            content: FittedBox(
              child: Column(children: <Widget>[
                Text("Pick a valid date and time!"),
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]),
            ),
          );
        },
      );
    } else {
      DateTime day6 = _day!;
      DateTime day4 = _day!.add(Duration(
        hours: int.parse(_time.split(":")[0]),
        minutes: int.parse(_time.split(":")[1].split(" ")[0]),
        seconds: 0,
      ));

      final isValid = _formKey.currentState?.validate();
      if (isValid != null) {
        _formKey.currentState?.save();
        final user = await FirebaseAuth.instance.currentUser;
        var userData = await FirebaseFirestore.instance
            .collection('donors')
            .doc(user?.uid)
            .get();

        try {
          setState(() {
            isLoading = true;
          });

          FirebaseFirestore.instance.collection('donors').doc(user?.uid).update({
            'address': address2,
          });

          DocumentReference document11 = FirebaseFirestore.instance
              .collection('donors')
              .doc(user?.uid)
              .collection('orders')
              .doc();
          document11.set({
            'time': Timestamp.now(),
            'range': range,
            'description': description,
            'veg': isVege,
            'nonVeg': isNVeg,
            'date': day4,
            'time1': _time,
            'status': false,
            'id': document11.id,
            'orderconfirmed': 'Not yet confirmed',
          });

          DocumentReference documentreference =
          FirebaseFirestore.instance.collection('orders').doc(document11.id);
          documentreference.set({
            'time': Timestamp.now(),
            'range': range,
            'description': description,
            'isVeg': isVege,
            'nonVeg': isNVeg,
            'address': address2,
            'typeofdonor': userData['type of donor'],
            'donorName': userData['username'],
            'email': userData['email'],
            'contact': contact,
            'username': userData['username'],
            'date': day4,
            'time1': _time,
            'id': document11.id,
            'userId': user?.uid,
            'status': false,
          });

          Navigator.of(context).popAndPushNamed(TickPage.routeName);
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
                content: FittedBox(
                  child: Column(children: <Widget>[
                    Text(err.message == null ? "sorry for inconvenience" : message),
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]),
                ),
              );
            },
          );

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
                    Text("Sorry for the inconvenience"),
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]),
                ),
              );
            },
          );

          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionFN.dispose();
    _contactFN.dispose();
    _addressFN.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.of(context).popAndPushNamed(DonorMain.routeName);
          },
        ),
        title: Text('Donate Now', style: TextStyle(color: Colors.white),),
      ),
      body: isLoading
          ? Center(
              child: Container(
              child: CircularProgressIndicator(),
              width: 20,
            ))
          : new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                // color: Colors.amber[50],
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: _formKey,
                  //autovalidateMode: _autoValidate,
                  child: ListView(children: <Widget>[
                    Container(
                      child: TextFormField(
                        controller: rangeIp,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                          enabledBorder: OutlineInputBorder(),
                          labelText: 'People you can serve',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val!.isEmpty || int.parse(val) <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          range = int.parse(value.trim());
                          FocusScope.of(context).requestFocus(_contactFN);
                        },
                        onSaved: (value) {
                          range = int.parse(value!.trim());
                        },
                      ),
                    ),
                    Divider(),
                    // SizedBox(height: 5),

                    Container(
                      child: TextFormField(
                        focusNode: _contactFN,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                          labelText: 'Your Contact Number',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty ||
                              double.parse(value.trim()) < 7000000000 ||
                              double.parse(value) <= 0) {
                            return 'Please enter a vaild contact number';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descriptionFN);
                        },
                        onSaved: (value) {
                          contact = int.parse(value!.trim());
                        },
                      ),
                    ),
                    Divider(),
                    Container(
                      child: TextFormField(
                        focusNode: _descriptionFN,
                        maxLines: 3,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(15.0),
                          labelText: 'Description of food',
                        ),
                        controller: descripIp,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Please enter valid description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          FocusScope.of(context).unfocus();
                          description = value;
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_addressFN);
                          description = value;
                        },
                      ),
                    ),
                    Divider(),
                    Container(
                      child: TextFormField(
                        // initialValue: '',
                        focusNode: _addressFN,
                        maxLines: 3,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(15.0),
                          labelText: ' Your Address',
                        ),
                        controller: addressIp,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        validator: (val) {
                          if (val!.isEmpty || val!.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          FocusScope.of(context).unfocus();
                          address2 = value;
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                          address2 = value;
                        },
                      ),
                    ),
                    Divider(),
                    Text('Available upto:'),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton(
                        style:ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          // DatePicker.showDatePicker(context,
                          //     theme: DatePickerTheme(
                          //       containerHeight: 210.0,
                          //     ),
                          //     showTitleActions: true,
                          //     minTime: DateTime.now(),
                          //     maxTime: DateTime.now().add(Duration(hours: 24)),
                          //     onConfirm: (date) {
                          //   print('confirm $date');
                          //   _date =
                          //       '${date.day} - ${date.month} - ${date.year}';
                          //   setState(() {
                          //     DateTime day5;
                          //     if (date.hour != 0 ||
                          //         date.minute != 0 ||
                          //         date.second != 0 ||
                          //         date.microsecond != 0 ||
                          //         date.millisecond != 0) {
                          //       day5 = date.subtract(Duration(
                          //           seconds: date.second,
                          //           hours: date.hour,
                          //           minutes: date.minute,
                          //           microseconds: date.microsecond,
                          //           milliseconds: date.millisecond));
                          //     } else {
                          //       day5 = date;
                          //     }
                          //     if (date
                          //         .subtract(Duration(hours: 24))
                          //         .isAfter(DateTime.now())) {
                          //       showDialog(
                          //           context: context,
                          //           builder: (ctx) {
                          //             return AlertDialog(
                          //                 elevation: 10,
                          //                 content: FittedBox(
                          //                     child: Column(children: <Widget>[
                          //                   Text('Oops something went wrong',
                          //                       style: TextStyle(
                          //                           fontSize: 18,
                          //                           fontWeight:
                          //                               FontWeight.bold)),
                          //                   SizedBox(height: 10),
                          //                   Text(
                          //                       ' Pickup up time should be within 24 hours from now ',
                          //                       style: TextStyle(fontSize: 16)),
                          //                 ])));
                          //           });
                          //     } else {
                          //       print(day5);
                          //       // print(date);
                          //       _day = day5;
                          //     }
                          //   });
                          // },
                          //     currentTime: DateTime.now(),
                          //     locale: LocaleType.en);
                          _selectDate(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.date_range,
                                          size: 18.0,
                                          color: Colors.pink,
                                        ),
                                        Text(
                                          " $_date",
                                          style: TextStyle(
                                              // color: Colors.pink,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(width: 30),
                              Text(
                                "Set a date",
                                style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.005,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          // DatePicker.showTimePicker(
                          //   context,
                          //   theme: DatePickerTheme(
                          //     containerHeight: 210.0,
                          //   ),
                          //   showTitleActions: true,
                          //   onConfirm: (time) {
                          //     print('confirm $time');
                          //     _time = '${time.hour} : ${time.minute} : ${time.second}';
                          //     setState(() {
                          //       _time1 = time;
                          //     });
                          //   },
                          //   currentTime: DateTime.now(),
                          //   locale: LocaleType.en,
                          // );
                          pickTime();
                          setState(() {});
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 18.0,
                                          color: Colors.pink,
                                        ),
                                        Text(
                                          " $_time",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(width: 30),
                              Text(
                                "Set a Time",
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Divider(),
                    Container(
                      child: Text(
                        'Food Category: ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      margin: EdgeInsets.all(10),
                    ),
                    CheckboxListTile(
                      title: Text(
                        'Veg: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      value: isVege,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          isVege = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Non-Veg: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      value: isNVeg,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          isNVeg = value!;
                        });
                      },
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        'Select any ONE checkbox',
                        style: TextStyle(
                          fontSize: 15,
                          color: _checkboxValid()
                              ? Colors.transparent
                              : Colors.red[900],
                        ),
                      ),
                    ),
                    Divider(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),

                    /*Container(
              
                          child:FlatButton.icon(
                            padding: EdgeInsets.all(10),
                          color: Colors.blueGrey[100],
                          onPressed: (){
                          if ( _validateInputs()){
                            return showDialog(
                             context: context,
                             builder: (context) {
                                return AlertDialog(
                          // Retrieve the text the that user has entered by using the
                          // TextEditingController.
                                  content: Text(
                                    'Are you sure?',
                                    style: TextStyle(
                                      fontSize: 20
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('No'),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Yes'),
                                     
                                      onPressed:(){ Navigator.of(context).pop();submit(); },
                                    ),
                                  ],
                                );
                            },
                          );
                          } else{
                            return null;
                          }
                          },
                          icon: Icon(Icons.group_add), 
                          label: Text('Donate'),  
                        ),
                           
                              ),*/
                  ]),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Container(
            color: Colors.black,
            child: ElevatedButton(
                onPressed: () {
                  if (_validateInputs()) {
                   showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          // Retrieve the text the that user has entered by using the
                          // TextEditingController.
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Are you sure you want to donate?',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'We assume that you take the responsibilty of the food you donate.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text('No',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: Text('Yes',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                submit();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return null;
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.group_add,
                      color: Colors.black,
                      size: 27,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Donate',
                      style: TextStyle(color: Colors.black, fontSize: 23),
                    ),
                  ],
                ))),
      ),
    );
  }
}
