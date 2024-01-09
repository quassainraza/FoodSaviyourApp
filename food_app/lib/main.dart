//import 'package:app1/welcome_page.dart';

import 'package:flutter/material.dart';
import 'package:food_app/screens/about.dart';
import 'package:food_app/screens/ongoing_orders.dart';
import 'package:food_app/screens/profile.dart';
import 'package:food_app/screens/yourorder.dart';
import 'package:food_app/sign_in.dart';
import 'package:food_app/spashScreen.dart';
import 'package:food_app/splash_screen.dart';

import './screens/past_orders_details.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/add_order.dart';
import './screens/donor_main.dart';
import './screens/tick.dart';
import './screens/receiver_home_screen.dart';
import './screens/donation_detail_screen.dart';
import './screens/confirm_order_screen.dart';
import './screens/pastorders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './screens/feedback_screen.dart';
import './screens/about1.dart';
import './widgets/tabs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import './sign_up.dart';

void main() async => {
WidgetsFlutterBinding.ensureInitialized(),
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
),
  runApp(MyApp())



}


;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDonor;
  bool isLoading = false;



  /* Future<void> check1() async {
    final user = await
     setState(() {
       isLoading=true;
     });
      final user=await FirebaseAuth.instance.currentUser();
    var userData =
        await Firestore.instance.collection('users').document(user.uid).get().then((value) {
          setState(() {
             isDonor=value['Donor'];
          });

        }).whenComplete(() {
           setState(() {
             print(isDonor);
       isLoading=false;
     });
        });


  }*/

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    return MaterialApp(
      title: 'Food Saviyour App',
      theme: ThemeData(
        fontFamily: 'Raleway',
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading state
              return CircularProgressIndicator(); // You can replace this with your loading widget
            }

            if (snapshot.hasData) {
              return FutureBuilder<User?>(
                future: Future.value(FirebaseAuth.instance.currentUser),
                builder: (ctx, futuresnapshot) {
                  if (futuresnapshot.connectionState == ConnectionState.waiting) {
                    // Loading state
                    return CircularProgressIndicator(); // You can replace this with your loading widget
                  }

                  if (futuresnapshot.connectionState == ConnectionState.done) {
                    return FutureBuilder(
                        future: Firestore.collection('users')
                            .doc(futuresnapshot.data?.uid)
                            .get(),
                        builder: (ctx, future1) {

                          if (future1.connectionState == ConnectionState.waiting) {
                            // Loading state
                            return CircularProgressIndicator(); // You can replace this with your loading widget
                          }

                          if (future1.connectionState == ConnectionState.done) {
                            final data = future1.data?.data();

                            if (data?['Donor'] == true) {
                              return DonorMain();
                            } else {
                              return ReceiverHomeScreen();
                            }
                          }
                          return CircularProgressIndicator();
                          if (future1.connectionState ==
                              ConnectionState.waiting) {
                            return SplashScreen();
                          }
                        });
                  }
                  if (futuresnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SplashScreen();
                  }
                  return CircularProgressIndicator();
                },

              );
            }
            return SplashScreen();
          }),
      routes: {
        PastOrdersScreen.routeName: (ctx) => PastOrdersScreen(),
        //ProfileScreen.routeName: (ctx) => ProfileScreen(),
        AboutUs.routeName: (ctx) => AboutUs(),
        AboutUs1.routeName: (ctx) => AboutUs1(),
        SplashScreen1.routeName: (ctx) => SplashScreen1(),
        SplashScreen.routeName: (ctx) => SplashScreen(),
        SignIn.routeName: (ctx) => SignIn(),
        AddOrder.routeName: (ctx) => AddOrder(),
        DonorMain.routeName: (ctx) => DonorMain(),
        TickPage.routeName: (ctx) => TickPage(),
        DonationDetailScreen.routeName: (ctx) => DonationDetailScreen(),
        ConfirmOrderScreen.routeName: (ctx) => ConfirmOrderScreen(),
        ReceiverHomeScreen.routeName: (ctx) => ReceiverHomeScreen(),
        FeedbackScreen.routeName: (ctx) => FeedbackScreen(),
        MyOrders.routeName: (ctx) => MyOrders(),
        Tabs.routeName: (ctx) => Tabs(),
        PastOrderDetailScreen.routeName: (ctx) => PastOrderDetailScreen(),
        OngoingOrders.routeName: (ctx) => OngoingOrders(),
      },
    );
  }
}
