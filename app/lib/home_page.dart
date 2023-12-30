import 'dart:io';

import "package:camera/camera.dart";
import 'package:test_app/camera_page.dart';
import 'package:test_app/input_page.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final String userID;
  const HomePage({Key? key, required this.userID}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color setColor = Colors.blue; // set the initial button color
  IconData setIcon = Icons.camera_alt_outlined; // set the initial button icon

  // set the album path, you should change this path manually
  String path = 'sdcard/Pictures';

  // set camera types
  List typeList = ['舌上', '舌下', '正臉', '左臉', '右臉'];

  // if the photo is taken, the button will change a color
  Color isPhotoTaken(String type) {
    String dirPath = '$path/flutter/${widget.userID}/$type';
    bool folder = Directory(dirPath).existsSync();

    if (folder) {
      setColor = Colors.green;
      return setColor;
    }
    setColor = Colors.blue;
    return setColor;
  }

  // if the photo is uploaded, the button will change a color
  Color isPhotoUploaded(String type) {
    String dirPath = '$path/flutter/${widget.userID}/$type';
    bool folder = Directory(dirPath).existsSync();

    if (folder) {
      setColor = Colors.green;
      return setColor;
    }
    setColor = Colors.blue;
    return setColor;
  }

  // if the photo is taken, the button will change an icon
  IconData iconChanged(String type) {
    bool folder =
        Directory('$path/flutter/${widget.userID}/$type').existsSync();
    if (folder) {
      setIcon = Icons.check_box_outlined;
      return setIcon;
    }
    setIcon = Icons.camera_alt_outlined;
    return setIcon;
  }

  // if the photo is taken, the button will change an icon
  IconData uploadIconChanged(String type) {
    bool folder =
        Directory('$path/flutter/${widget.userID}/$type').existsSync();
    if (folder) {
      setIcon = Icons.check_box_outlined;
      return setIcon;
    }
    setIcon = Icons.upload_file_outlined;
    return setIcon;
  }

  // if return true, this function is useless
  Future<bool> _onWillPop() async {
    return (await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const InputPage()))) ??
        false;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive',
      'https://www.googleapis.com/auth/drive.file'
    ],
  );

  Future<UserCredential> _signIn() async {
    final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> uploadToDrive() async {
    final mimeType = "application/vnd.google-apps.folder";
    const String driveID =
        '1OEhnNqOPjvk5JMRRBQ3Zqd3DqcQZSiFb'; // google drive ID
    final folder = '$path/flutter/${widget.userID}';
    final localDirectory = Directory(folder);
    final entities = localDirectory.listSync(recursive: true);
    print(entities);
    print('12345');

    // final found = await driveApi.files.list(
    //   q: "mimeType = '$mimeType' and name = '$folder'",
    //   $fields: "files(id, name)",
    // );

    // create a folder in google grive
    drive.File driveFolder = drive.File();
    driveFolder.name = widget.userID;
    // driveFolder.mimeType
  }

  @override
  Widget build(BuildContext context) {
    String userID = widget.userID;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Home Page"),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InputPage()));
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                  )),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SafeArea(
                      child: Center(
                          child: Text('User ID: ${widget.userID}',
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold)))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWidget(
                      cameraType: typeList[0],
                      iconChanged: iconChanged(typeList[0]),
                      isPhotoTaken: isPhotoTaken(typeList[0]),
                      userID: userID,
                      cameraTypeList: typeList),
                  ButtonWidget(
                      cameraType: typeList[1],
                      iconChanged: iconChanged(typeList[1]),
                      isPhotoTaken: isPhotoTaken(typeList[1]),
                      userID: userID,
                      cameraTypeList: typeList),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWidget(
                      cameraType: typeList[2],
                      iconChanged: iconChanged(typeList[2]),
                      isPhotoTaken: isPhotoTaken(typeList[2]),
                      userID: userID,
                      cameraTypeList: typeList),
                  ButtonWidget(
                      cameraType: typeList[3],
                      iconChanged: iconChanged(typeList[3]),
                      isPhotoTaken: isPhotoTaken(typeList[3]),
                      userID: userID,
                      cameraTypeList: typeList),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWidget(
                      cameraType: typeList[4],
                      iconChanged: iconChanged(typeList[4]),
                      isPhotoTaken: isPhotoTaken(typeList[4]),
                      userID: userID,
                      cameraTypeList: typeList),
                  SafeArea(
                      child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton.icon(
                        // upload to google drive
                        onPressed: () {
                          _signIn().then((value) => uploadToDrive());
                        },
                        icon: Icon(
                          uploadIconChanged(userID),
                          size: 30.0,
                        ),
                        label: const Text(
                          '上傳相片',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Color.fromARGB(255, 237, 236, 236),
                              fontWeight: FontWeight.bold),
                        ),
                        style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all<Size>(
                                const Size(120.0, 100.0)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                isPhotoUploaded(userID))),
                      ),
                    ),
                  ))
                ],
              ),
            ],
          ),
        ));
  }
}

// Set button widget
class ButtonWidget extends StatelessWidget {
  final String cameraType;
  final IconData iconChanged;
  final Color isPhotoTaken;
  final String userID;
  final List cameraTypeList;

  const ButtonWidget(
      {super.key,
      required this.cameraType,
      required this.iconChanged,
      required this.isPhotoTaken,
      required this.userID,
      required this.cameraTypeList});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton.icon(
          // go to CameraPage
          onPressed: () async {
            await availableCameras().then((value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraPage(
                            cameras: value,
                            userID: userID,
                            typeList: cameraTypeList,
                            cameraType: cameraType,
                          )),
                ));
          },
          icon: Icon(
            iconChanged,
            size: 30.0,
          ),
          label: Text(
            cameraType,
            style: const TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 237, 236, 236),
                fontWeight: FontWeight.bold),
          ),
          style: ButtonStyle(
              fixedSize:
                  MaterialStateProperty.all<Size>(const Size(120.0, 100.0)),
              backgroundColor: MaterialStateProperty.all<Color>(isPhotoTaken)),
        ),
      ),
    ));
  }
}
