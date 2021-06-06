import 'package:flutter/material.dart';
import 'package:notedemoapp/pages/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: NoteList(),
    );
  }
}
