import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note_application/database_helper.dart';
import 'package:note_application/models/note.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail(this.note, this.appBarTitle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static const List<String> _priorities = ['High', 'Low'];
  final DatabaseHelper helper = DatabaseHelper();

  final String appBarTitle;
  final Note note;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.titleLarge;

    titleController.text = note.title;
    descriptionController.text = note.description ?? '';

    return WillPopScope(
      onWillPop: () async {
        moveToLastScreen();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: <Widget>[
              // Priority Dropdown
              ListTile(
                title: DropdownButton<String>(
                  items: _priorities.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (String? selectedPriority) {
                    setState(() {
                      if (selectedPriority != null) {
                        debugPrint('User selected $selectedPriority');

                        updatePriorityAsInt(selectedPriority);
                      }
                    });
                  },
                ),
              ),

              // Title TextField
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Title updated');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              // Description TextField
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Description updated');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              // Save and Delete Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: <Widget>[
                    // Save Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark,
                          foregroundColor: Theme.of(context).primaryColorLight,
                          textStyle: const TextStyle(fontSize: 16.0),
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('Save button clicked');
                            _save();
                          });
                        },
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark,
                          foregroundColor: Theme.of(context).primaryColorLight,
                          textStyle: const TextStyle(fontSize: 16.0),
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('Delete button clicked');
                            _delete();
                          });
                        },
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    note.priority = value == 'High' ? 1 : 2;
  }

  String getPriorityAsString(int value) {
    return value == 1 ? _priorities[0] : _priorities[1];
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  Future<void> _delete() async {
    moveToLastScreen();

    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    int result = await helper.deleteNote(note.id!);
    _showAlertDialog(
      'Status',
      result != 0 ? 'Note Deleted Successfully' : 'Error Deleting Note',
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }
}
