import 'package:flutter/material.dart';
import 'package:notedemoapp/models/notemodel.dart';
import 'package:notedemoapp/pages/note_detail.dart';
import 'package:notedemoapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();

  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Note> noteList = [];
  int count = 0;
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    if (noteList.length == 0) {
      noteList = [];
      updateListView();
    }

    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text('Not Listesi'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Ekleye Basıldı");
          navigateToDetail(Note('', '', 2, ''), 'Not Ekle');
        },
        tooltip: "Not Ekle",
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ListView getNoteListView() {
    TextStyle? titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 1.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(this.noteList[position].title, style: titleStyle),
              subtitle: Text(this.noteList[position].description),
              trailing: Wrap(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      debugPrint("List tetiklendi.");
                      navigateToDetail(this.noteList[position], "Not Düzenle");
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.grey,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _delete(context, noteList[position]);
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onTap: () {},
            ),
          );
        });
  }

  void naviteToDetail(Note note, String baslik) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, baslik)));
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;

      case 2:
        return Colors.yellow;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.arrow_upward);

      case 2:
        return Icon(Icons.arrow_downward);

      default:
        return Icon(Icons.arrow_downward);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id ?? 0);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void navigateToDetail(Note note, String title) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    updateListView();
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
