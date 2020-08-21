import 'dart:async';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lightning Talk Gong',
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
        title: Text('Lightning Talk Gong'),
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
    if (timer != null && timer.isActive) {
      print("timer is active, returning");
      return;
    }
    print("timerStart");
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

    Process.run('paplay', ['gong.wav'], workingDirectory: envVars['SNAP']).then((ProcessResult results) {
      print(results.stdout);
      print(results.stderr);
    });
  }

  void gong() async {
    gongSound();

    var sessionBus = DBusClient.session();
    var client = NotificationClient(sessionBus);
    await client.notify('The gong has gone bong, time to leave the stage!');
    await sessionBus.disconnect();
  }
}
