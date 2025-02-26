import 'package:flutter/material.dart';
import 'dart:async'; //for components that change every interval of second(s)
import 'package:flutter_map/flutter_map.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  late Timer _timer; // will be initialized in the startTimer method
  //variables of time left and to be changed when connected to the car physically
  //variables are just demo & shouldn't be used when connected to car
  int _sec = 60;
  int _min = 1;
  int _hour = 0;
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_sec == 0) {
          if (_min == 0 && _hour == 0) {
            // all are zeros so timer should stop
            setState(() {
              timer.cancel();
            });
          } else if (_min == 0) {
            //sec and min are zeros, so hours should be decremented and min & sec restart
            setState(() {
              _hour--;
              _min = 60;
              _sec = 60;
            });
          } else {
            //only sec are zeros so just decrement min and restart sec
            setState(() {
              _min--;
              _sec = 60;
            });
          }
        } else {
          //base case
          setState(() {
            _sec--;
          });
        }
      },
    );
  }
// following to methods can be used to start and stop the timer for future uses with the code
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

  Widget build(BuildContext context) {
    String formattedTime =
        "${_hour.toString().padLeft(2, '0')}:${_min.toString().padLeft(2, '0')}:${_sec.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
          title: const Text('Current Trip Details'),
          backgroundColor: Colors.blueGrey),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                const Text(
                  "Estimated time left for the current trip:  ",
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                    onPressed: () {
                      startTimer();
                    },
                    child: const Text('start'))
              ],
            ),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            Expanded(
              child: Row(
                children: [
                  Center(
                    child: SizedBox(
                      width: 500,
                      child: FlutterMap(
                        options: const MapOptions(
                          initialZoom: 13.0, // Initial zoom level
                        ),
                        children: [
                          // to integrate with OpenStreetMap:
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ),
                        ],
                      ),
                    ),
                  ),
                  FloatingActionButton(
                      onPressed: () {},
                      child: const Column(
                        children: [Text('add stop'), Icon(Icons.add)],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
