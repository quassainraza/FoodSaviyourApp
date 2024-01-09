import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
   CountDownTimer({
    Key? key,
    required int secondsRemaining,
    required this.whenTimeExpires,
    required this.countDownFormatter, required TextStyle countDownStyle, required this.countDownTimerStyle,
  })  : secondsRemaining = secondsRemaining,
        super(key: key);

  final int secondsRemaining;
  final Function whenTimeExpires;
  final Function countDownFormatter;
  final TextStyle countDownTimerStyle;

  State createState() => new _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Duration duration;
  String formatHHMMSS(int seconds) {
  int hours = (seconds / 3600).truncate();
  seconds = (seconds % 3600).truncate();
  int minutes = (seconds / 60).truncate();

  String hoursStr = (hours).toString().padLeft(2, '0');
  String minutesStr = (minutes).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  if (hours == 0) {
    return "$minutesStr:$secondsStr";
  }

  return "$hoursStr:$minutesStr:$secondsStr";
}

  String get timerDisplayString {
    Duration duration = _controller.duration! * _controller.value;
    return widget.countDownFormatter != null
        ? widget.countDownFormatter(duration.inSeconds)
        : formatHHMMSS(duration.inSeconds);
      // In case user doesn't provide formatter use the default one
     // for that create a method which will be called formatHHMMSS or whatever you like
  }

  @override
  void initState() {
    super.initState();
    duration = new Duration(seconds: widget.secondsRemaining);
    _controller = new AnimationController(
      vsync: this,
      duration: duration,
    );
    _controller.reverse(from: widget.secondsRemaining.toDouble());
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        widget.whenTimeExpires();
      }
    });
  }

  @override

  void didUpdateWidget(CountDownTimer oldWidget) {
    if (widget.secondsRemaining != oldWidget.secondsRemaining) {
      duration = new Duration(seconds: widget.secondsRemaining);
      _controller.dispose();
      _controller = new AnimationController(
        vsync: this,
        duration: duration,
      );
      _controller.reverse(from: widget.secondsRemaining.toDouble());
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.whenTimeExpires();
        } else if (status == AnimationStatus.dismissed) {
          print("Animation Complete");
        }
      });
      setState(() {}); // Only call setState if needed
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(
            animation: _controller,
            builder: (_, Widget? child) {
              return Text(
                timerDisplayString,
                style:TextStyle(color: Colors.grey,fontSize: 23,fontWeight: FontWeight.bold),
              );
            });
  }
}