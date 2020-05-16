import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../util/DBhelper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  NoteDetailState createState() => NoteDetailState(this.note, this.appBarTitle);
}

class NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;
  static var _priorities = ['High', 'Low'];
  DatabaseHelper databaseHelper = DatabaseHelper();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          goBack();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              onPressed: () {
                goBack();
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((dropdownItem) {
                        return DropdownMenuItem<String>(
                          value: dropdownItem,
                          child: Text(dropdownItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: updatePriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) => note.title = titleController.text,
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) =>
                        note.description = descriptionController.text,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            onPressed: () {
                              setState(() {
                                _save();
                              });
                            },
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            )),
                      ),
                      Container(width: 5.0),
                      Expanded(
                        child: RaisedButton(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            onPressed: () {
                              setState(() {
                                _delete();
                              });
                            },
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void goBack() {
    Navigator.pop(context, true);
  }

  //convert string priority to int priority
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

  String updatePriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //high
        break;
      case 2:
        priority = _priorities[1]; //low
        break;
    }
    return priority;
  }

  void _save() async {

    if(note.title.isEmpty) {
      _showAlertDialog('Status', 'No Title Inputted');
      return;
    }
    goBack();
    int result;
    note.date = DateFormat.yMMMMd().format(DateTime.now());


    if (note.id != null) {
      //update op
      result = await databaseHelper.updateNote(note);
    } else {
      // insert op
      result = await databaseHelper.insertNote(note);
    }

    if(result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {

    goBack();

    if(note.id == null) {
      _showAlertDialog('Status', 'No Note Was Deleted');
      return;
    } else {
      int result = await databaseHelper.deleteNote(note.id);
      if(result != null) {
        _showAlertDialog('Status', 'Note Deleted Successfully');
      } else {
        _showAlertDialog('Status', 'Error Occured');
      }

    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

//  void updateTitle() {
//    note.title = titleController.text;
//  }
}
