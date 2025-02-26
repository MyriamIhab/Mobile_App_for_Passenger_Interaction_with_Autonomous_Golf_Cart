import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:yolo_realtime_plugin/yolo_realtime_plugin.dart';
import 'package:flutter/services.dart'; // to enforce landscape view

class YoloRealTimeViewExample extends StatefulWidget {
  const YoloRealTimeViewExample({Key? key}) : super(key: key);

  @override
  State<YoloRealTimeViewExample> createState() =>
      _YoloRealTimeViewExampleState();
}

class _YoloRealTimeViewExampleState extends State<YoloRealTimeViewExample> {
  late CameraController cameraController;
  late CameraImage imgCamera;
  bool isCameraInitialized = false;
  late YoloRealtimeController yoloController;
  bool isYoloInitialized = false;
  List<String> activeClasses = [
    "car",
    "person",
    "tv",
    "laptop",
    "mouse",
    "bottle",
    "cup",
    "keyboard",
    "cell phone",
  ];

  List<String> fullClasses = [
    "person",
    "bicycle",
    "car",
    "motorcycle",
    "airplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "fire hydrant",
    "stop sign",
    "parking meter",
    "bench",
    "bird",
    "cat",
    "dog",
    "horse",
    "sheep",
    "cow",
    "elephant",
    "bear",
    "zebra",
    "giraffe",
    "backpack",
    "umbrella",
    "handbag",
    "tie",
    "suitcase",
    "frisbee",
    "skis",
    "snowboard",
    "sports ball",
    "kite",
    "baseball bat",
    "baseball glove",
    "skateboard",
    "surfboard",
    "tennis racket",
    "bottle",
    "wine glass",
    "cup",
    "fork",
    "knife",
    "spoon",
    "bowl",
    "banana",
    "apple",
    "sandwich",
    "orange",
    "broccoli",
    "carrot",
    "hot dog",
    "pizza",
    "donut",
    "cake",
    "chair",
    "couch",
    "potted plant",
    "bed",
    "dining table",
    "toilet",
    "tv",
    "laptop",
    "mouse",
    "remote",
    "keyboard",
    "cell phone",
    "microwave",
    "oven",
    "toaster",
    "sink",
    "refrigerator",
    "book",
    "clock",
    "vase",
    "scissors",
    "teddy bear",
    "hair drier",
    "toothbrush"
  ];
  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeYolo();
  }

  void initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await cameraController.initialize();
    cameraController.startImageStream((imageFromStream) {
      setState(() {
        imgCamera = imageFromStream;
        isCameraInitialized = true;
      });
    });
  }

  void initializeYolo() async {
    yoloController = YoloRealtimeController(
      fullClasses: fullClasses,
      activeClasses: activeClasses,
      androidModelPath: 'models/yolov5s_320.pt',
      androidModelWidth: 320,
      androidModelHeight: 320,
      androidConfThreshold: 0.5,
      androidIouThreshold: 0.5,
    );
    try {
      setState(() {
        yoloController.initialize();
        isYoloInitialized = true;
      });
    } catch (e) {
      print('ERROR: $e');
      isYoloInitialized = false;
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    // yoloController.dispose();
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
            ? (!isYoloInitialized
                ? AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  )
                : YoloRealTimeView(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    controller: yoloController,
                    drawBox: true,
                    captureBox: (boxes) {
                      // print(boxes);

                    },
                    captureImage: (data) async {
                      // print('binary image: $data');

                      /// Process and use the binary image as you wish.
                      // imageToFile(data);
                    },
                  ))
            : CircularProgressIndicator(),
      ),
    );
  }

  // void detectObjects() async {
  //   try {
  //     final recognizedObjects = await yoloController.detectObjectsOnFrame(
  //       imgCamera.planes[0].bytes,
  //       imgCamera.width,
  //       imgCamera.height,
  //     );
  //     // Process detected objects and display them
  //     displayDetectedObjects(recognizedObjects);
  //   } catch (e) {
  //     print('Error detecting objects: $e');
  //   }
  // }
  //
  // void displayDetectedObjects(List<DetectedObject> objects) {
  //   // Draw bounding boxes or overlay detected objects on the camera preview
  //   // You can use CustomPaint or other widgets to draw bounding boxes
  //   // Example:
  //   CustomPaint(
  //     painter: ObjectDetectionPainter(objects, imgCamera.width, imgCamera.height),
  //     child: AspectRatio(
  //       aspectRatio: cameraController.value.aspectRatio,
  //       child: CameraPreview(cameraController),
  //     ),
  //   );
  // }
}
