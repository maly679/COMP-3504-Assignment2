// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COMP 3504 - Assignment 2 - Group 4',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _data = '';

  // This function is triggered when the user presses the floating button
  Future<void> _loadData() async {
    final _loadedData = await rootBundle.loadString('assets/items.txt');
    setState(() {
      _data = _loadedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventroy Tracker'),
      ),
      body: Center(
          child: Container(
              width: 300,
              child: Text(_data != null ? _data : 'Nothing to show',
                  style: TextStyle(fontSize: 24)))),
      floatingActionButton:
      FloatingActionButton(onPressed: _loadData, child: Icon(Icons.add)),
    );
  }
}