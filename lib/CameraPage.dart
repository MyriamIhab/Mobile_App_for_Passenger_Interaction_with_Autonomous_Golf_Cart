import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController cameraController;
  late CameraImage imgCamera;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController.initialize();
    cameraController.startImageStream((imageFromStream) {
      setState(() {
        imgCamera = imageFromStream;
        isCameraInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera's View"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: isCameraInitialized
            ? TextButton(
                onPressed: () {
                  // Do nothing on button press
                },
                child: AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController),
                ),
              )
            : CircularProgressIndicator(), // Show loading indicator until camera is initialized
      ),
    );
  }
}
