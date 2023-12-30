import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_app/home_page.dart';
import 'package:test_app/input_page.dart';
import 'package:screen_brightness/screen_brightness.dart';

class DisplayPage extends StatefulWidget {
  final XFile imagePath;
  final String luxString;
  final String userID;
  final String type;

  const DisplayPage(
      {Key? key,
      required this.imagePath,
      required this.luxString,
      required this.userID,
      this.type = 'none'})
      : super(key: key);

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  // if return true, this function is useless
  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  void initState() {
    super.initState();
    ScreenBrightness().resetScreenBrightness();
  }

  @override
  void dispose() {
    super.dispose();
    ScreenBrightness().setScreenBrightness(1);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    // get current time, format = yyyyMMdd_HHmmss, UTC + 8
    String currentTime =
        "${now.year.toString()}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

    // get preview name
    String pictureName =
        '${widget.userID}_${widget.type}_${widget.luxString}_$currentTime.jpg';

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Display Page"),
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
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.file(File(widget.imagePath.path),
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.7),
            const SizedBox(
              height: 12,
            ),
            Text(pictureName,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: MediaQuery.of(context).size.height * 0.05,
                      icon: const Icon(
                        Icons.backspace_outlined,
                      ),
                      onPressed: () async {
                        await availableCameras().then((value) => Navigator.pop(
                              context,
                            ));
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final tempDir =
                            await getApplicationDocumentsDirectory();
                        final File output = await File(widget.imagePath.path)
                            .copy('${tempDir.path}/$pictureName');

                        await GallerySaver.saveImage(output.path,
                                albumName:
                                    'flutter/${widget.userID}/${widget.type}') // save picture
                            .then((value) => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Uploaded to Album!'))))
                            .then((value) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(userID: widget.userID))));
                      },
                      child: const Text(
                        'Save Photo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: MediaQuery.of(context).size.height * 0.05,
                      icon: const Icon(
                        Icons.home_outlined,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(userID: widget.userID)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ])),
        ));
  }
}
