import "package:flutter/material.dart";
import "package:note_keeper/screens/note_detail.dart";
import "package:note_keeper/screens/note_list.dart";

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple, // Apply globally
        ),
      ),
      home: NoteList(),
    );
  }
}
