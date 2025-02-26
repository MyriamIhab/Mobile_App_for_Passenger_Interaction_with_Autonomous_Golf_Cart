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
import 'package:yolo_realtime_plugin/yolo_realtime_plugin.dart';
import 'MenuPage.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with TickerProviderStateMixin {
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
  bool controllerIsRunning = false;

  List<l.LocationData> locations = [];

  double speedCounter = 0;
  double speedRounded = 0;

  @override
  void initState() {
    super.initState();
    getLocation();
    checkStatus();

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
      controllerIsRunning = false;
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
        backgroundColor: Colors.blueGrey,
        title: const Text('Current Location'),
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                    height: MediaQuery.of(context).size.height - 85,
                    width: MediaQuery.of(context).size.width - 85,
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
                            Container(
                              width: 100,
                              height: 100,
                              child: Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: SfRadialGauge(
                                        axes: <RadialAxis>[
                                          RadialAxis(
                                            minimum: 0,
                                            maximum: 200,
                                            showFirstLabel: false,
                                            showLabels: false,
                                            // useRangeColorForAxis: true,
                                            axisLabelStyle: const GaugeTextStyle(
                                              color: Colors.white, // Change number color here
                                              fontSize: 20,
                                            ),
                                            ranges: <GaugeRange>[
                                              GaugeRange(
                                                startValue: 0,
                                                endValue: 60,
                                                color: Colors.green,
                                              ),
                                              GaugeRange(
                                                  startValue: 60,
                                                  endValue: 120,
                                                  color: Colors.amber[700]),
                                              GaugeRange(
                                                  startValue: 120,
                                                  endValue: 200,
                                                  color: Colors.red[800])
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
                                                              color: Colors.black))),
                                                  angle: 90,
                                                  positionFactor: 0.5)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
