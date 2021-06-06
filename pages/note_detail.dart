import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notedemoapp/models/notemodel.dart';
import 'package:notedemoapp/utils/database_helper.dart';

// ignore: must_be_immutable
class NoteDetail extends StatefulWidget {
  final String baslik;
  final Note note;
  NoteDetail(this.note, this.baslik);
  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.baslik);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _onemListesi = ["Yüksek", "Düşük"];
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String baslik = '';
  Note note;
  _NoteDetailState(this.note, String baslik);

  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context).textTheme.bodyText1;

    titleController.text = note.title;
    descriptionController.text = note.description;
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text(baslik),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            moveToLastScreen();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Text(
                      "Önem Derecesi :  ",
                      style: titleStyle,
                    ),
                    Expanded(
                      child: DropdownButton(
                        items: _onemListesi.map((String dropItem) {
                          return DropdownMenuItem(
                            value: dropItem,
                            child: Text(dropItem),
                          );
                        }).toList(),
                        style: titleStyle,
                        value: getPriorityAsString(note.priority),
                        onChanged: (secim) {
                          setState(() {
                            print("Kullanıcı $secim 'i seçti");
                            updatePriorityAsInt(secim as String);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Başlık
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                  controller: titleController,
                  style: titleStyle,
                  onChanged: (deger) {
                    print("baslik degisti : $deger");
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: "Başlık",
                      labelStyle: titleStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)))),
            ),
            //Açıklama
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                  controller: descriptionController,
                  style: titleStyle,
                  onChanged: (deger) {
                    print("açıklama degisti : $deger");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "Açıklama",
                      labelStyle: titleStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)))),
            ),
            //KaydetButton
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          Text("Kaydet"),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          print("kaydet'e basıldı");
                          _save();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled))
                            return Colors.red;
                          return Colors.red; // Defer to the widget's default.
                        }),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete),
                          Text("Sil"),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          print("Sil'e basıldı");
                          _delete();
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'Yüksek':
        note.priority = 1;
        break;
      case 'Düşük':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority = "";
    switch (value) {
      case 1:
        priority = _onemListesi[0]; // 'High'
        break;
      case 2:
        // ignore: unnecessary_cast
        priority = _onemListesi[1]; // 'Low'
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
  // ignore: unused_element
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMd().format(DateTime.now());
    int result;

    int? noteId = note.id;
    // ignore: unnecessary_null_comparison
    if (noteId != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Kayıt Başarılı');
    } else {
      // Failure
      _showAlertDialog('Kayıt Hatası');
    }
  }

  // ignore: unused_element
  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    // ignore: unnecessary_null_comparison
    if (note.id == null) {
      _showAlertDialog('Kayıt silinemedi!');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id ?? 0);
    if (result != 0) {
      _showAlertDialog('Kayıt başarıyla silindi.');
    } else {
      _showAlertDialog('Kayıt silinirken hata oluştu.');
    }
  }

  void _showAlertDialog(String message) {
    final snackBar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     // return object of type Dialog
    //     return AlertDialog(
    //       title: new Text("Mesaj"),
    //       content: new Text(message),
    //       actions: <Widget>[
    //         // usually buttons at the bottom of the dialog
    //         new ElevatedButton(
    //           child: new Text("Kapat"),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
