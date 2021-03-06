import 'package:flutter/material.dart';
import 'package:notekr/NoteDetails.dart';
import 'models/Note.dart';
import 'package:sqflite/sqflite.dart';
import 'utils/database_helper.dart';
import 'dart:async';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;

  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("FAB tapped");
          navigateToDetail(Note('', '', 2), "Add Note");
        },
        child: Icon(Icons.add),
        tooltip: "Add note",
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) => Card(
        color: Colors.white,
        elevation: 2.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: getPriorityColor(this.noteList[index].priority),
            child: getPriorityIcon(this.noteList[index].priority),
          ),
          title: Text(
            this.noteList[index].title,
            style: titleStyle,
          ),
          subtitle: Text(this.noteList[index].date),
          trailing: GestureDetector(
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onTap: () {
              _delete(context, noteList[index]);
            },
          ),
          onTap: () {
            debugPrint("Tile Clicked");
            navigateToDetail(this.noteList[index], "Edit Note");
          },
        ),
      ),
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.orange;
        break;
      case 2:
        return Colors.lightGreen;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.warning);
        break;
      case 2:
        return Icon(Icons.check);
        break;
      default:
        return Icon(Icons.pause_circle_outline);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted Succesfully");
    }
    updateListView();
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetails(note, title)));
    if (result) {
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
