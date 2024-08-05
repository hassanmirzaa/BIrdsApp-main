import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? scanPic;
  bool imageselected = false;
  String? predictedSpecies;
  String? confidence;
  String? description;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _selectImageFromCamera();
  }

  Future<void> _selectImageFromCamera() async {
    XFile? selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      File convertedFile = File(selectedImage.path);
      setState(() {
        imageselected = true;
        scanPic = convertedFile;
      });
      print("Image selected");
      _uploadImage(convertedFile);
    } else {
      setState(() {
        errorMessage = "Image is not selected";
      });
      print("Image is not selected");
    }
  }

  Future<void> _uploadImage(File image) async {
    setState(() {
      errorMessage = null;
    });

    final client = http.Client();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.104:8000/predict/'), // Your local IP address and port
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      final response = await client.send(request).timeout(Duration(seconds: 60)); // Increased timeout
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseBody);
        setState(() {
          predictedSpecies = decodedResponse['Predicted Species'];
          confidence = decodedResponse['Confidence'];
          description = decodedResponse['Description'];
        });
        print("Prediction: $predictedSpecies, Confidence: $confidence, Description: $description");
      } else {
        setState(() {
          errorMessage = "Failed to get prediction. Status code: ${response.statusCode}";
        });
        print("Failed to get prediction. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
      print("Error: $e");
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/settings.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.grey.withOpacity(0.5),
                    image: scanPic != null
                        ? DecorationImage(
                            image: FileImage(scanPic!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageselected
                      ? null
                      : const Icon(
                          Icons.add_photo_alternate,
                          color: Colors.blue,
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _selectImageFromCamera();
                  },
                  child: const Text("Retake"),
                ),
                const SizedBox(height: 20),
                if (predictedSpecies != null && confidence != null && description != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Predicted Species: $predictedSpecies',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Confidence: $confidence',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description: $description',
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
