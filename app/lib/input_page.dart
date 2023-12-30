import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_app/home_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('Do you want to exit the app?'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No')),
                    TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        child: const Text('Yes'))
                  ],
                ))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'\d{3}$'); // RegExp(r'^[A-Z][12]\d{6}$')

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Input Page'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ('User ID can\'t be empty');
                      }
                      if (!regex.hasMatch(value)) {
                        return ('Invalid user ID');
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: myController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '請輸入受試者編號三碼',
                      helperText: 'e.g. 001',
                      hintText: 'User ID',
                    ),
                  ),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.27,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                        onPressed: () async {
                          String userID = myController.text;
                          if (regex.hasMatch(userID) && userID.isNotEmpty) {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(userID: userID)));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        child: const Text('Enter'))),
              ],
            ))));
  }
}
