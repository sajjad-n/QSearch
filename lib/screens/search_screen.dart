import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qsearch/classes/file_class.dart';
import 'package:qsearch/G.dart' as G;
import 'package:qsearch/modules/search_engine_module.dart';
import 'package:qsearch/screens/show_doc_screen.dart';

import 'manage_doc_screen.dart';

class SearchScreen extends StatefulWidget{
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _txtEdtController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<FileClass> _docList = [];
  bool _nothingFound = false;

  @override
  void initState() {
    super.initState();
    G.createDirectory();
  }

  @override
  Widget build(BuildContext context) {
    var _topPadding = MediaQuery.of(context).padding.top + 10;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xff383838),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/search_background.png'),
              fit: BoxFit.cover
            )
          ),
          child: Column(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: _topPadding),
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 200,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xff696969),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              autofocus: false,
                              scrollPhysics: BouncingScrollPhysics(),
                              controller: _txtEdtController,
                              cursorColor: Color(0xff8772FF),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18
                              ),
                              decoration: InputDecoration(
                                  hintText: 'جستجو کنید ...',
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18
                                  ),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color(0xff8772FF),
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: _onSearchClick,
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: _nothingFound == false
                    ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _docList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => _onDocClick(
                        docName: _docList[index].fileName,
                        content: _docList[index].content
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _docList[index].fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _docList[index].content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Text(
                                  'امتیاز:',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  _docList[index].score,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : _showNothingFound()
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff8772FF),
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 28,
          ),
          onPressed: _onDocEditClick,
        ),
      ),
    );
  }

  void _onSearchClick() async{
    String _searchTxt = _txtEdtController.value.text;
    if (_searchTxt == '') {
        _showMessageInSnackBar(error: 'ابتدا فیلد را تکمیل کنید.');
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
      Map docScores = await new SearchEngineModule(context: context, query: _searchTxt).search();
      Map sortedScores = _sortScores(scores: docScores);
      _showResults(scores: sortedScores);
    }
  }

  Map _sortScores({Map scores}) {
    var sortedKeys = scores.keys.toList()
      ..sort((k1, k2) => scores[k2].compareTo(scores[k1]));
    LinkedHashMap sortedMap = new LinkedHashMap
        .fromIterable(sortedKeys, key: (k) => k, value: (k) => scores[k]);
    return sortedMap;
  }

  void _showResults({Map scores}) {
    _docList.clear();
    scores.forEach((docName, score) {
      String docPath = G.documentPath + '/$docName';
      _docList.add(
          FileClass(
            fileName: docName,
            filePath: docPath,
            score: score.toStringAsFixed(3),
            content: _getContent(path: docPath)
          ));
    });

    if (_docList.isEmpty)
      _nothingFound = true;
    else
      _nothingFound = false;

    setState(() {});
  }

  Widget _showNothingFound() {
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

  String _getContent({String path}) {
    File file = new File(path);
    return file.readAsStringSync();
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

  void _onDocEditClick() {
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            pageBuilder: (context, animation, secondaryAnimation) => ManageDocScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            })
    );
  }

  void _onDocClick({String docName, String content}) {
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            pageBuilder: (context, animation, secondaryAnimation) => ShowDocScreen(
              docName: docName,
              content: content,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            })
    );
  }

}