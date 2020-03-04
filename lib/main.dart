import 'dart:async';
import 'dart:io';
import 'package:dbus_client/dbus_client.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Ubuntu'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer timer;
  DateTime startTime;
  var duration = Duration(minutes: 5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Gong'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.asset('assets/gong.jpg')),
            Text(
              (timer == null
                      ? duration.toString()
                      : (duration - DateTime.now().difference(startTime)))
                  .toString()
                  .split('.')[0],
              style: TextStyle(fontSize: 40),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: timerStart,
            child: Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
            onPressed: timerStop,
            child: Icon(Icons.restore),
          ),
        ],
      ),
    );
  }

  void timerStart() {
    setState(() {
      startTime = DateTime.now();
    });

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if ((duration - DateTime.now().difference(startTime)).inSeconds <= 0) {
        timerStop();
        gong();
      }
      setState(() {});
    });
  }

  void timerStop() {
    if (timer != null) {
      timer.cancel();
      timer = null;
      setState(() {});
    }
  }

  void gongSound() async {
    Map<String, String> envVars = Platform.environment;
    print(envVars['SNAP']);
    print(envVars['PWD']);

    Process.run('paplay', ['gong.wav'], workingDirectory: envVars['SNAP']).then((ProcessResult results) {
      print(results.stdout);
      print(results.stderr);
    });
  }

  void gong() async {
    gongSound();
    var client = DBusClient.session();
    await client.connect();
    var hints = DBusDict(DBusSignature('s'), DBusSignature('v'));
    hints.add(DBusString('sound-name'), DBusVariant(DBusString('bell-terminal')));
    var values = [
      DBusString(''), // App name
      DBusUint32(0), // Replaces
      DBusString(''), // Icon
      DBusString('The gong has gone bong, time to leave the stage!'), // Summary
      DBusString(''), // Body
      DBusArray(DBusSignature('s')), // Actions
      hints, // Hints
      DBusInt32(-1), // Expire timeout
    ];
    var result = await client.callMethod(
        destination: 'org.freedesktop.Notifications',
        path: '/org/freedesktop/Notifications',
        interface: 'org.freedesktop.Notifications',
        member: 'Notify',
        values: values);
    var id = (result[0] as DBusUint32).value;
    debugPrint('notify $id');
  }
}
