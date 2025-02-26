import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CarPage.dart';
import 'LocationPage.dart';
import 'TimeDate_Page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Menu'),
      ),
      body: Center(
        child: Container(
          //color: Colors.blueGrey[800],
          child: Table(
            //This table contains all the buttons that will render to all other
            // pages that allows the passenger to interact with the car
            // border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Column(
                      children: [
                        Icon(
                          Icons.report,
                          color: Colors.red,
                          size: 100,
                        ),
                        Text("Stop Now!"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarPage(),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 100,
                        ),
                        Text("Access the car"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationPage(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Image(
                          image: const AssetImage('images/car&trip.png'),
                          color: Theme.of(context).primaryColor,
                        ),
                        const Text("Current Location"),
                      ],
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Column(
                      children: [
                        Icon(
                          Icons.headset,
                          size: 100,
                        ),
                        Text("play music"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TimeDate_Page(),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 100,
                        ),
                        Text("Time & Date"),
                      ],
                    ),
                  ),
                  Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
