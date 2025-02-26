import 'package:flutter/material.dart';

//import 'CameraPage.dart';
import 'SpeedoMeterPage.dart';
import 'YoloRealTimeViewExample.dart';

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  // features that are car-related: battery - cameras views - lidars data
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  int _batteryCounter = 50; //to be changed of the real readings from the car
  // following methods are expected to be removed after connecting to the car
  void _incrementBattery() {
    if (_batteryCounter < 100) {
      setState(() {
        _batteryCounter += 10;
      });
    }
  }

  void _decrementBattery() {
    if (_batteryCounter > 0) {
      setState(() {
        _batteryCounter -= 10;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('My Car'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              color: Colors.grey[50],
              child: Row(
                children: [
                  Icon(
                    Icons.battery_charging_full,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    "Car's battery is ",
                    style: TextStyle(
                        fontSize: 50, color: Theme.of(context).primaryColor),
                  ),
                  Text(
                    "$_batteryCounter %  ",
                    style: TextStyle(
                        fontSize: 50, color: Theme.of(context).primaryColor),
                  ),
                  FloatingActionButton(
                    heroTag: 'incrementBattery',
                    onPressed: _incrementBattery,
                    tooltip: 'Increment',
                    child: const Icon(
                      Icons.add,
                      size: 20,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'decrementBattery',
                    onPressed: _decrementBattery,
                    tooltip: 'Decrement',
                    child: const Icon(
                      Icons.remove,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Table(
                children: [
                  TableRow(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const YoloRealTimeViewExample(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Image(
                              image: const AssetImage('images/playVideo.png'),
                              color: Theme.of(context).primaryColor,
                            ),
                            const Text("What my car sees!"),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //navigate to the page of displaying the car
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SpeedoMeterPage(
                                title: 'Speedometer',
                              ),
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Icon(
                              Icons.speed,
                              size: 100,
                            ),
                            Text("Car's Speed"),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Column(
                          children: [
                            Image(
                              image: const AssetImage(
                                  'images/car&surrounding.png'),
                              color: Theme.of(context).primaryColor,
                            ),
                            const Text("Lidars Data"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
