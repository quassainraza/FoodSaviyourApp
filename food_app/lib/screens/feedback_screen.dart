import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';

class FeedbackScreen extends StatefulWidget {
  static const routeName = 'feedback-screen';
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Give Feedback'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'Rate our Donor:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                AnimatedRatingStars(
                  initialRating: 3.5,
                  minRating: 0.0,
                  maxRating: 5.0,
                  filledColor: Colors.amber,
                  emptyColor: Colors.grey,
                  filledIcon: Icons.star,
                  halfFilledIcon: Icons.star_half,
                  emptyIcon: Icons.star_border,
                  onChanged: (double rating) {
                    // Handle the rating change here
                    print('Rating: $rating');
                  },
                  displayRatingValue: true,
                  interactiveTooltips: true,
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                  starSize: 30.0,
                  animationDuration: Duration(milliseconds: 300),
                  animationCurve: Curves.easeInOut,
                  readOnly: false,
                ),
                    SizedBox(height: 10,),
                Text(
                  'Let the donor know if you have some suggestions',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(5),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: TextField(
                    maxLines: 10,
                    decoration: InputDecoration(
                      labelText: 'Give Feedback',
                      labelStyle: TextStyle(color: Colors.black45,letterSpacing: 12)
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
