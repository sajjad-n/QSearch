import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qsearch/classes/file_class.dart';
import 'package:path/path.dart';
import 'package:qsearch/modules/indexing_module.dart';
import 'package:qsearch/G.dart' as G;

class ManageDocScreen extends StatefulWidget{
  @override
  _ManageDocScreenState createState() => _ManageDocScreenState();
}

class _ManageDocScreenState extends State<ManageDocScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _fileNameController = new TextEditingController();
  TextEditingController _fileContentController = new TextEditingController();
  List<FileClass> _docList = new List<FileClass>();
  Future _readDocFuture;
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _readDocFuture = _readDocuments();
  }

  @override
  Widget build(BuildContext context) {
    var _topPadding = MediaQuery.of(context).padding.top + 10;
    var _screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: ()=> _onExit(context: context),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xff383838),
          body: Container(
            width: _screenSize.width,
            height: _screenSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/search_background.png'),
                fit: BoxFit.cover
              )
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: _topPadding),
                Text(
                  'مدیریت داکیومنت ها',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: _screenSize.width,
                  height: 1,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder(
                    future: _readDocFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return _docList.isEmpty
                            ? _showEmptyList()
                            : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: _docList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return index != _docList.length-1
                                ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: ExpansionTile(
                                  title: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          _docList[index].fileName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: ()=> _showDocDialog(context: context, isEdit: true, currentFile: _docList[index]),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: ()=> _onDocDeleteClick(file: _docList[index]),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _docList[index].content,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                                : Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 50),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: ExpansionTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _docList[index].fileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: ()=> _showDocDialog(context: context, isEdit: true, currentFile: _docList[index]),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: ()=> _onDocDeleteClick(file: _docList[index]),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _docList[index].content,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }
                      else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff8772FF)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xff8772FF),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => _showDocDialog(context: context),
          ),
        ),
      ),
    );
  }

  Widget _showEmptyList() {
    return Center(
      child: Text(
        'موردی یافت نشد!',
        style: TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontWeight: FontWeight.w400
        ),
      ),
    );
  }

  Future<bool> _onExit({BuildContext context}) async{
    if (_didChange)
      await new IndexingModule(context: context).index();
    return Future.value(true);
  }

  Future<void> _readDocuments() async{
    print('\nreading documents ...');
    _docList.clear();

    var dir = Directory(G.documentPath);
    List files = await dir.list().toList();
    for (var file in files){
      File f = new File(file.path);
      String content = await f.readAsString();
      _docList.add(
        FileClass(
          fileName: basename(f.path),
          content: content,
          filePath: f.path
        )
      );
    }

    // reverse list from new to old
    _docList = _docList.reversed.toList();
    print('${_docList.length} documents found.\n');
  }

  void _showDocDialog({BuildContext context, bool isEdit = false, FileClass currentFile}) {
    if (isEdit) {
      String fileName = currentFile.fileName.substring(0, currentFile.fileName.length - 4);
      _fileNameController.text = fileName;
      _fileContentController.text = currentFile.content;
    } else {
      _fileNameController.text = '';
      _fileContentController.text = '';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Color(0xff383838),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        title: Center(
          child: Text(
            isEdit ? 'ویرایش داکیومنت' : 'افزودن داکیومنت جدید',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400
            ),
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                TextField(
                  autofocus: true,
                  scrollPhysics: BouncingScrollPhysics(),
                  controller: _fileNameController,
                  cursorColor: Color(0xff8772FF),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16
                  ),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xff696969),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      hintText: 'نام',
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  autofocus: false,
                  scrollPhysics: BouncingScrollPhysics(),
                  controller: _fileContentController,
                  cursorColor: Color(0xff8772FF),
                  maxLines: 13,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16
                  ),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xff696969),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      hintText: 'محتوا',
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            splashColor: Colors.white.withOpacity(0.3),
            child: Text(
              'انصراف',
              style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ) ,
          FlatButton(
              splashColor: Colors.white.withOpacity(0.3),
              child: Text(
                  'ثبت',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16
                  )
              ),
              onPressed: () {
                String fileName = _fileNameController.text.toString();
                String fileContent = _fileContentController.text.toString();
                Navigator.pop(context);
                isEdit
                    ? _replaceDoc(oldFile: currentFile, newName: fileName, newContent: fileContent)
                    : _saveDoc(name: fileName, content: fileContent);
              }
          )
        ],
      ),
    );
  }

  void _onDocDeleteClick({FileClass file}) {
    final dir = Directory(file.filePath);
    dir.deleteSync(recursive: true);
    print('\nDocument removed from: ${file.filePath}\n');
    _showMessageInSnackBar(error: 'داکیومنت با موفقیت حذف شد.');
    _didChange = true;
    setState(() {
      _readDocFuture = _readDocuments();
    });
  }

  void _saveDoc({String name, String content}) {
    if (_nameExist(name: name)) {
      print('\nDuplicate name\n');
      _showMessageInSnackBar(error: 'نام داکیومنت تکراری می باشد.');
    } else {
      File file = new File('${G.documentPath}/$name.txt');
      file.writeAsStringSync(content);
      print('\nNew Document Saved in: ${file.path}\n');
      _showMessageInSnackBar(error: 'داکیومنت با موفقیت ذخیره شد.');
      _didChange = true;
      setState(() {
        _readDocFuture = _readDocuments();
      });
    }
  }

  bool _nameExist({String name}) {
    name = '$name.txt';
    for (FileClass file in _docList) {
      if (file.fileName == name) {
        return true;
      }
    }
    return false;
  }

  void _replaceDoc({FileClass oldFile, String newName, String newContent}) {
    // remove old file
    final dir = Directory(oldFile.filePath);
    dir.deleteSync(recursive: true);
    print('\nOld file deleted from: ${oldFile.filePath}');

    // save new file
    File file = new File('${G.documentPath}/$newName.txt');
    file.writeAsStringSync(newContent);
    print('New file saved in: ${G.documentPath}/$newName.txt\n');

    _showMessageInSnackBar(error: 'داکیومنت با موفقیت ویرایش شد.');
    _didChange = true;
    setState(() {
      _readDocFuture = _readDocuments();
    });
  }

  void _showMessageInSnackBar({String error}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      content: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: Colors.black),
            SizedBox(width: 8),
            Text(error),
          ],
        ),
      ),
    ));
  }

}