import 'package:flutter/material.dart';
import 'dart:async'; //for components that change every interval of second(s)

class TimeDate_Page extends StatefulWidget {
  const TimeDate_Page({super.key});

  @override
  State<TimeDate_Page> createState() => _TimeDate_PageState();
}

class _TimeDate_PageState extends State<TimeDate_Page> {
  int _day = DateTime.now().day;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  int _hour = DateTime.now().hour;
  int _min = DateTime.now().minute;
  int _sec = DateTime.now().second;
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          _day = DateTime.now().day;
          _month = DateTime.now().month;
          _year = DateTime.now().year;
          _hour = DateTime.now().hour;
          if (_hour > 12) {
            _hour = _hour - 12;
          }
          _min = DateTime.now().minute;
          _sec = DateTime.now().second;
        });
      },
    );
  }

  Widget build(BuildContext context) {
    startTimer();
    String formattedTime =
        "${_hour.toString().padLeft(2, '0')}:${_min.toString().padLeft(2, '0')}:${_sec.toString().padLeft(2, '0')}";
    String formattedDate =
        "${_day.toString().padLeft(2, '0')}/${_month.toString().padLeft(2, '0')}/${_year.toString().padLeft(4, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time & Date'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height - 90,
          width: MediaQuery.of(context).size.width,
          // padding: EdgeInsets.only(top: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade400,
            width: 100), // Add black border
          ),
          child: Container(
            padding: EdgeInsets.only(top: 60), // Add padding for content
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey.shade200,
                  width: 100), // Add black border
            ),
            child: Column(
              children: [
                Text(
                  formattedTime,
                  style:
                      const TextStyle(fontSize: 50, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedDate,
                  style:
                      const TextStyle(fontSize: 50, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
