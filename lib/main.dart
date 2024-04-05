import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firebaseStorage = FirebaseStorage.instance;
  final storageBuckets =
      FirebaseStorage.instanceFor(bucket: "gs://fir-test-51a6b.appspot.com");

  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _imageUrls = [];
  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery App'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemBuilder: (context, index) {
                return Image.network(_imageUrls[index]);
              },
              itemCount: _imageUrls.length,
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Visibility(
          visible: _inProgress == false,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: FloatingActionButton(
            onPressed: _pickImages,
            backgroundColor: Colors.amber,
            child: const Icon(
              Icons.camera,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    _inProgress = true;
    setState(() {});
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageLocation =
          storageBuckets.ref().child("images/${DateTime.now()}.jpg");

      UploadTask uploadOperation = imageLocation.putFile(File(pickedFile.path));

      TaskSnapshot uploadDone = await uploadOperation.whenComplete(() => null);
      String downloadUrl = await uploadDone.ref.getDownloadURL();
      _imageUrls.add(downloadUrl);
      _inProgress = false;
      setState(() {});
    }
  }
}
