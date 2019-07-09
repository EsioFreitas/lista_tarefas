import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  final _toDoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text("ADD"),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: toDo,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: buildItem,
              padding: EdgeInsets.only(top: 10),
              itemCount: _toDoList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
            color: Colors.red,
            child: Align(
                alignment: Alignment(-0.9, 0), child: Icon(Icons.delete))),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          onChanged: (c) {
            setState(() {
              _toDoList[index]['ok'] = c;
              _saveData();
            });
          },
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
              child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error)),
        ),
        onDismissed: (direction) {
          setState(() {
            final _lastRemoved = Map.from(_toDoList[index]);
            final _lastRemovedIdx = index;
            _toDoList.removeAt(index);
            _saveData();
            final snack = SnackBar(
                content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
                action: SnackBarAction(
                    label: "Desfazer",
                    onPressed: () {
                      setState(() {
                        _toDoList.insert(_lastRemovedIdx, _lastRemoved);
                        _saveData();
                      });
                    }),
                duration: Duration(seconds: 2));
            Scaffold.of(context).showSnackBar(snack);
          });
        });
  }

  void toDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _toDoController.text;
      _toDoController.text = "";
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
