import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qsearch/classes/file_class.dart';
import 'package:qsearch/G.dart' as G;
import 'package:path/path.dart';

import 'dart:convert';

class IndexingModule {
  List<FileClass> _docList = new List<FileClass>();
  Map _invertedIndex = {}; // term : { docName : tf }
  final BuildContext context;
  int _docCount; // used for idf in ltc

  IndexingModule({this.context});

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          AlertDialog(
            backgroundColor: Color(0xff383838),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            title: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Color(0xff8772FF)),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'در حال ایندکس سازی ...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Future<void> index() async {
    print('\nGenerating inverted index ...');
    _showLoading();
    await _readDocuments();
    _generateInvertedIndex();
    print('Inverted index: $_invertedIndex');
    _save();
    Navigator.pop(context);
  }

  Future<void> _readDocuments() async {
    print('reading documents ...');
    _docList.clear();

    var dir = Directory(G.documentPath);
    List files = await dir.list().toList();
    _docCount = files.length;
    for (var file in files) {
      File f = new File(file.path);
      String content = await f.readAsString();
      content = content.replaceAll('\n', ' '); // remove new ines
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
    print('${_docList.length} documents found.');
  }

  void _generateInvertedIndex() {
    for (FileClass doc in _docList) {
      List<String> termList = G.findTerms(content: doc.content);
      termList.forEach((term) {
        if (!_invertedIndex.containsKey(term))
          // make new pair
          _invertedIndex[term] = {doc.fileName : _tf(term: term, list: termList)};
        else
          // add to existing pair
          _invertedIndex[term].putIfAbsent(doc.fileName, ()=> _tf(term: term, list: termList));
      });
    }
  }

  int _tf({String term, List<String> list}) {
    int count = 0;
    list.forEach((t) {
      if (term == t)
        count++;
    });
    return count;
  }

  void _save() {
    // save inverted index
    File fi = new File('${G.invertedPath}/invertedIndex.txt');
    fi.writeAsStringSync(json.encode(_invertedIndex));
    print('Inverted index saved in: ${fi.path}');

    // save doc count
    File fd = new File('${G.invertedPath}/docCount.txt');
    fd.writeAsStringSync(_docCount.toString());
  }

}