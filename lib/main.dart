import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  // instance created
  final firebaseStorage = FirebaseStorage.instance;

  // Storage bucket
  final storageBuckets =
      FirebaseStorage.instanceFor(bucket: "gs://fir-test-51a6b.appspot.com");

  final ImagePicker _imagePicker = ImagePicker();
  final List _imageUrls = [];

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
          ElevatedButton(
              onPressed: _uploadImage, child: const Text('Pick images')),
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
    );
  }

  Future<void> _uploadImage() async {
    // image picker used
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // image upload operation
      final imageLocation =
          storageBuckets.ref().child("images/${pickedFile.name}");

      UploadTask uploadOperation = imageLocation.putFile(File(pickedFile.path));

      // print(uploadOperation);
      // .split('/').last
      // if (kDebugMode) {
      //   print(pickedFile.path.split('/').last);
      // }
      TaskSnapshot uploadDone = await uploadOperation.whenComplete(() => null);
      String downloadUrl = await uploadDone.ref.getDownloadURL();
      _imageUrls.add(downloadUrl);
      setState(() {});
    }
  }
}
