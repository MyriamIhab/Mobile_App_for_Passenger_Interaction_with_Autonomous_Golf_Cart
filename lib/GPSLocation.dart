import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GPSLocation extends StatefulWidget {
  const GPSLocation({super.key});

  @override
  State<GPSLocation> createState() => _GPSLocationState();
}

class _GPSLocationState extends State<GPSLocation> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(30.113680477258267, 31.344596710689803);
  static const LatLng destination  = LatLng(29.98678068467674, 31.44153732272571);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trip info",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: sourceLocation, zoom: 13.5),
        markers: {
          Marker(markerId: MarkerId("source"), position: sourceLocation),
          Marker(markerId: MarkerId("destination"), position: destination),
        },
      )
    );
  }
}
