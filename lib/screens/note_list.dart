import 'package:flutter/material.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'note_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  int count = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];

  void initState(){
    super.initState();
    updateListView();
  }
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB clicked");
          navigateToDetail(Note('', '', 2, ''), "Add Note");
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    //TextStyle titleStyle = Theme.of(context).textTheme.titleMedium;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
              ),
              subtitle: Text(
                this.noteList[position].date,
              ),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");

                navigateToDetail(this.noteList[position], 'Edit Note');
              },
            ),
          );
        });
  }

// Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellowAccent;
        break;
      default:
        return Colors.yellowAccent;
        break;
    }
  }

  // Returns the priority icon

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
        break;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int? noteId = note.id;

    if (noteId == null) {
      _showSnackBar(context, 'Error: could not delete note');
    } else {
      int result = await databaseHelper.deleteNote(noteId);
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
