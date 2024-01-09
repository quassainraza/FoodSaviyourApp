import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';


class Orders{
  final bool isVeg;
  final String description;
  final double range;
   DateFormat? date;

  Orders({
    required this.range,
    required this.isVeg,
    required this.description,
   this.date,
  });

}
