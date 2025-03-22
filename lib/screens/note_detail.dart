import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'note_list.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  var _formkey = GlobalKey<FormState>();
  static var _priorities = ['High', 'Low'];
  var _currentSelectedItem = 'Low';
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String appBarTitle;
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description;
    return
        //PopScope(
        // canPop: false,
        // onPopInvokedWithResult: moveToLastScreen(),
        // child:
        Scaffold(
            appBar: AppBar(
              // leading: IconButton(
              //     onPressed: () {
              //       moveToLastScreen();
              //     },
              //     icon: Icon(Icons.arrow_back)),
              title: Text(
                this.appBarTitle,
                style: TextStyle(color: Colors.white),
              ),
            ),
             body: Form(
               key: _formkey,
                child: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: ListView(
                children: [
                  ListTile(
                    title: DropdownButton<String>(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      onChanged: <String>(selectedItem) {
                        setState(() {
                          _currentSelectedItem = selectedItem;
                          updatePriorityAsInt(selectedItem);
                        });
                      },
                      value: getPriorityAsString(note.priority),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: titleController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Note Title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        debugPrint('Something changed in the Title TextField');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: descriptionController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Note Title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        debugPrint(
                            'Something changed in the Description TextField');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {

                                  setState(() {
                                    if(_formkey.currentState!.validate()) {
                                      debugPrint("Save button clicked");
                                      _save();
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                  textScaler: TextScaler.linear(1.5),
                                ))),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Delete button clicked");
                                    _delete();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                  textScaler: TextScaler.linear(1.5),
                                ))),
                      ],
                    ),
                  )
                ],
              ),
            ),
            ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

// Convert String priority in the form of integer before saving it to Database

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

// Convert int priority to String priority and display it to user in DropDown

  String getPriorityAsString(int value) {
    String priority = 'Low';
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

// Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

// Update the description of Note object

  void updateDescription() {
    note.description = descriptionController.text;
  }

// Save data to database
  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format((DateTime.now()));
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert operation
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    int? noteId = note.id;
    if (noteId == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2:  User is trying to delete the old note that already has a valid ID.

    int result = await helper.deleteNote(noteId);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
