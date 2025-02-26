import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csvwriter/csvwriter.dart';

import 'MenuPage.dart';
//import 'package:tflite/tflite.dart';

// main function is the starting point for all our flutter apps
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: MyHomePage(storage: CounterStorage()),
    );
  }
}
class CounterStorage {
  var writeFile;
  List<List<dynamic>> allData = [];
  var time=0;
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // print('directory path');
    // print(directory);

    return directory.path;

  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('path');
    print(path);

    final csvFile= File('$path/counter.csv');
    final csvSink = csvFile.openWrite(mode: FileMode.write);
    var sinkIsClosed = false;
    csvSink.done.whenComplete(() {
      sinkIsClosed = true;
    });
    writeFile = CsvWriter.withHeaders(csvSink, ['Time','Longitude', 'Latitude']);
    return csvFile;
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      print('file data');
      print(contents);
      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(double long, double lat) async {
    final file = await _localFile;

    // Write the file
    var contents = await file.readAsString();
    time+=1;
    allData.add([time,long,lat]);
    for(int i=0; i<allData.length; i++){
      writeFile.writeData(data: {'Time': allData[i][0], 'Longitude': allData[i][1], 'Latitude': allData[i][2]});
      contents = await file.readAsString();
    }
    // writeFile.writeData(data: {'Number': '$counter', 'Counter': '$counter'});
    print('contents after');
    print(contents);
    // return writeFile;
    // return file.writeAsString('$counter');

    return file;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.storage});

final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool gpsEnabled = false;
  bool permissionGranted = false;
  l.Location location = l.Location();
  late StreamSubscription subscription;
  bool trackingEnabled = false;
  late LatLng currentLocation;
  bool isCurrentLocationInit = false;
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);
  MapController mapController = MapController();
  Timer? timer;
  Timer? controllerTimer;
  Timer? csvTimer;

  bool csvRun=false;
  bool controllerIsRunning = false;

  List<l.LocationData> locations = [];

  double speedCounter = 0;
  double speedRounded = 0;

  @override
  void initState() {
    super.initState();
    getLocation();
    checkStatus();
    widget.storage.readCounter();
    // testCSV();
    // startTimer();
    // startControllerTimer();
  }


  @override
  void dispose() {
    stopTracking();
    timer?.cancel();
    stopControllerTimer();
    super.dispose();
  }

  Future<void> getLocation() async {
    permission_GPS();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      isCurrentLocationInit = true;
    });
    startTimer();
    startControllerTimer();
    startCSVTimer();
  }

  Future<void> permission_GPS() async {
    //for asking to enable GPS
    if (gpsEnabled) {
      log("Already open");
    } else {
      bool isGpsActive = await location.requestService();
      if (!isGpsActive) {
        setState(() {
          gpsEnabled = false;
        });
        log("User did not turn on GPS");
      } else {
        log("gave permission to the user and opened it");
        setState(() {
          gpsEnabled = true;
        });
      }
    }

    // to request permission if not given
    PermissionStatus permissionStatus =
    await Permission.locationWhenInUse.request();
    if (permissionStatus == PermissionStatus.granted) {
      setState(() {
        permissionGranted = true;
      });
    } else {
      setState(() {
        permissionGranted = false;
      });
    }
  }

  checkStatus() async {
    bool _permissionGranted = await isPermissionGranted();
    bool _gpsEnabled = await isGpsEnabled();
    setState(() {
      permissionGranted = _permissionGranted;
      gpsEnabled = _gpsEnabled;
    });
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

        widget.storage.writeCounter(position.longitude, position.latitude);

        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          speedCounter = speedKmph;
          speedRounded = double.parse(
              speedCounter.toStringAsFixed(1)); // 1 is the decimal length
        });
      },
    );
  }

  void startControllerTimer() {
    const oneSec = Duration(seconds: 2);
    if (!controllerIsRunning) {
      controllerIsRunning = true;
      controllerTimer = Timer.periodic(oneSec, (Timer timer) {
        mapController.move(currentLocation, 17.5);
      });
    }
  }

  void stopControllerTimer() {
    if (controllerIsRunning) {
      controllerTimer?.cancel();
      csvTimer?.cancel();
      csvRun = false;
      controllerIsRunning = false;
      stopCSVTimer();
    }
  }

  void startCSVTimer() {
    const oneSec = Duration(seconds: 1);
    if (!csvRun) {
      csvRun = true;
      csvTimer = Timer.periodic(
        oneSec,
            (Timer timer) async {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          widget.storage.writeCounter(position.longitude, position.latitude);
        },
      );
    }
  }
  void stopCSVTimer() {
    if (csvRun) {
      csvTimer?.cancel();
      csvRun = false;
    }
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isGpsEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  // void _incrementSpeed() {
  //   setState(() {
  //     if (speedCounter < 200) {
  //       speedCounter += 10;
  //     }
  //   });
  // }
  //
  // void _decrementSpeed() {
  //   setState(() {
  //     if (speedCounter > 0) {
  //       speedCounter -= 10;
  //     }
  //   });
  // }

  void stopTracking() {
    subscription.cancel();
    setState(() {
      trackingEnabled = false;
    });
    clearLocation();
  }

  clearLocation() {
    setState(() {
      locations.clear();
    });
  }

  Future<void> calculateSpeed() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final double speedMps = position.speed; // Speed in meters per second
    final double speedKmph = speedMps * 3.6; // Convert to kilometers per hour

    setState(() {
      speedCounter = speedKmph;
      speedRounded = double.parse(
          speedCounter.toStringAsFixed(1)); // 1 is the decimal length
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, size: 50,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height - 85,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            FlutterMap(
                              mapController: mapController,
                              options: const MapOptions(
                                initialZoom: 17.0,
                                // minZoom: 13.0,
                                maxZoom: 20,
                                initialCenter: LatLng(
                                    29.98678068467674, 31.44153732272571),
                              ),
                              children: [
                                // to integrate with OpenStreetMap:
                                TileLayer(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                ),
                                // AnimatedMarkerLayer(
                                //   markers: [
                                //     AnimatedMarker(
                                //       rotate: true,
                                //       point: isCurrentLocationInit
                                //           ?currentLocation
                                //           :LatLng(29.98678068467674, 31.44153732272571),
                                //       builder: (_, animation) {
                                //         final size = 50.0 * animation.value;
                                //         _animatedMapController.animateTo(
                                //           zoom: 17.5,
                                //           dest: isCurrentLocationInit
                                //               ?currentLocation
                                //               :LatLng(29.98678068467674, 31.44153732272571),
                                //         );
                                //         return Icon(
                                //           Icons.location_on_sharp,
                                //           size: size,
                                //           color: Colors.red,
                                //         );
                                //       },
                                //     ),
                                //   ],
                                // ),
                                isCurrentLocationInit
                                    ? MarkerLayer(
                                        rotate: true,
                                        markers: [
                                          Marker(
                                            width: 40.0,
                                            height: 40.0,
                                            point: currentLocation,
                                            child: Icon(
                                              Icons.location_on,
                                              color: Colors.blue,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                              ],
                            ),
                            Column(
                              verticalDirection: VerticalDirection.up,
                              children: [
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: FloatingActionButton(
                                    onPressed: startControllerTimer,
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_location_outlined),
                                        const Text("Re-center"),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 50,
                                  child: FloatingActionButton(
                                    onPressed: stopControllerTimer,
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_off_outlined),
                                        const Text("Stop Tracking"),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    // Expanded(
                    //   child: ListView.builder(
                    //     itemCount: locations.length,
                    //     itemBuilder: (context, index) {
                    //       return ListTile(
                    //         title: Text(
                    //             "${locations[index].latitude} ${locations[index].longitude}"),
                    //       );
                    //     },
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey,
                      child: SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(
                            minimum: 0,
                            maximum: 200,
                            showLastLabel: true,
                            useRangeColorForAxis: true,
                            axisLabelStyle: const GaugeTextStyle(
                              color: Colors.white, // Change number color here
                              fontSize: 20,
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
                                value: speedRounded,
                                enableAnimation: true,
                                gradient: LinearGradient(colors: [Colors.blueGrey,Colors.white,]),
                                //needleColor: Colors.white,
                              )
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Container(
                                      child: Text('$speedRounded',
                                          style: const TextStyle(
                                              fontSize: 30,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
