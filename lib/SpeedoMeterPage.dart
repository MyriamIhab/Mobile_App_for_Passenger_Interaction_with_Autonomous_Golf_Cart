import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; //for the speedometer

class SpeedoMeterPage extends StatefulWidget {
  const SpeedoMeterPage({super.key, required this.title});
  final String title;

  @override
  State<SpeedoMeterPage> createState() => _SpeedoMeterPageState();
}

class _SpeedoMeterPageState extends State<SpeedoMeterPage> {
  double speedCounter = 0;
  Timer? timer;
  // void _incrementSpeed() {
  //   setState(() {
  //     if (_counter < 200) {
  //       _counter += 10;
  //     }
  //   });
  // }
  //
  // void _decrementSpeed() {
  //   setState(() {
  //     if (_counter > 0) {
  //       _counter -= 10;
  //     }
  //   });
  // }
  void initState() {
    super.initState();
    startTimer();
  }

  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
          (Timer timer) async {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final double speedMps = position.speed; // Speed in meters per second
        final double speedKmph =
            speedMps * 3.6; // Convert to kilometers per hour

        setState(() {
          speedCounter = double.parse(
              speedKmph.toStringAsFixed(1));;
          // speedRounded = double.parse(
          //     speedCounter.toStringAsFixed(1)); // 1 is the decimal length
        });
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text('Speedometer'),
        // body: Image(
        //   image:
        // ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 200,
                      showLastLabel: true,
                      useRangeColorForAxis: true,
                      axisLabelStyle: const GaugeTextStyle(
                        color: Colors.white, // Change number color here
                        fontSize: 30,
                      ),
                      ranges: <GaugeRange>[
                        GaugeRange(
                          startValue: 0,
                          endValue: 60,
                          color: Colors.lightGreenAccent[400],
                        ),
                        GaugeRange(
                            startValue: 60,
                            endValue: 120,
                            color: Colors.yellowAccent),
                        GaugeRange(
                            startValue: 120,
                            endValue: 200,
                            color: Colors.redAccent)
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: speedCounter,
                          enableAnimation: true,
                          gradient: LinearGradient(colors: [Colors.blueGrey,Colors.white,]),
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Text('$speedCounter',
                                    style: const TextStyle(
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                            angle: 90,
                            positionFactor: 0.5)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Row(
            //   children: [
            //     FloatingActionButton(
            //       heroTag: 'incrementSpeed',
            //       onPressed: _incrementSpeed,
            //       tooltip: 'Increment',
            //       child: const Icon(Icons.add),
            //     ),
            //     FloatingActionButton(
            //       heroTag: 'decrementBattery',
            //       onPressed: _decrementSpeed,
            //       tooltip: 'Decrement',
            //       child: const Icon(Icons.remove),
            //     ),
            //   ],
            // ),
          ],
        ),

        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
