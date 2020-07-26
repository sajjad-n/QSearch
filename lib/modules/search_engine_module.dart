import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qsearch/G.dart' as G;
import 'package:qsearch/classes/term_class.dart';

import 'indexing_module.dart';

class SearchEngineModule {
  Map _invertedIndex = {};
  List<TermClass> _queryTermList = [];
  List<TermClass> _docTermList = [];
  final String query;
  final BuildContext context;

  SearchEngineModule({this.context, this.query});

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
                    'در حال جستجو ...',
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

  Future<Map> search() async{
    Map scores = {}; // docName : score
    _showLoading();
    await _readInvertedIndex();
    if (_invertedIndex.isNotEmpty) {
      _ltc();
      _lnc();
      scores = _calculateScore();
    }
    else
      print('Inverted index is empty!\n');
    Navigator.pop(context);
    return scores;
  }

  Future<void> _readInvertedIndex() async{
    if (await File('${G.invertedPath}/invertedIndex.txt').exists()) {
      print('\nReading inverted index file ...');
      File f = new File('${G.invertedPath}/invertedIndex.txt');
      String content = await f.readAsString();
      _invertedIndex = json.decode(content);
      print('Inverted index: $_invertedIndex\n\n');
    }
    else {
      print('\nInverted index file does\'nt exist!');
      await new IndexingModule(context: context).index();
      await _readInvertedIndex();
    }
  }

  int _docCount() {
    File file = new File('${G.invertedPath}/docCount.txt');
    int docCount = int.parse(file.readAsStringSync());
    return docCount;
  }

  List<String> _getQueryTerms() {
    List<String> terms = G.findTerms(content: query);
    terms.toSet().toList().forEach((term) { // first remove duplicate terms then do foreach
      _queryTermList.add(
        TermClass(
          term: term
        )
      );
    });
    return terms;
  }

  int _tf({List<String> allTerms, String term}) {
      int count = 0;
      allTerms.forEach((at) {
        if (at == term)
          count++;
      });
      return count;
  }

  double _tf_wt({int tf}) {
    return 1 + (log(tf) / ln10);
  }

  int _df({String term}) {
    if (_invertedIndex.containsKey(term))
      return _invertedIndex[term].length;
    else
      return 0;
  }

  double _idf({int df}) {
    if (df == 0)
      return 0;
    int n = _docCount();
    return log(n / df) / ln10;
  }

  double _tf_idf({double tf_wt, double idf}) {
    return tf_wt * idf;
  }

  void _ltc() {
    print('---------- calculating LTC ----------\n\n');
    List<String> allTerms = _getQueryTerms();
    double vectorValue = 0;
    for (TermClass t in _queryTermList) {
      t.tf_raw = _tf(allTerms: allTerms, term: t.term);
      t.tf_wt = _tf_wt(tf: t.tf_raw);
      t.df = _df(term: t.term);
      t.idf = _idf(df: t.df);
      t.tf_idf = _tf_idf(tf_wt: t.tf_wt, idf: t.idf);
      vectorValue += pow(t.tf_idf, 2);
    }
    vectorValue = sqrt(vectorValue);
    _ltcNormalize(vectorValue: vectorValue);
  }

  void _ltcNormalize({double vectorValue}) {
    _queryTermList.forEach((t) {
      if (t.tf_idf == 0)
        t.normal_tf_idf = 0.0;
      else
        t.normal_tf_idf = t.tf_idf / vectorValue;
      print('---------------------------');
      print('       ${t.term}');
      print('---------------------------');
      print('tf: ${t.tf_raw}\ntf_wt: ${t.tf_wt}\ndf: ${t.df}\nidf: ${t.idf}\ntf.idf: ${t.tf_idf}\nvector_value: $vectorValue\nnormal_tf.idf: ${t.normal_tf_idf}\n\n');
    });
  }

  void _lnc() {
    print('\n\n---------- calculating LNC ----------\n\n');
    for (TermClass t in _queryTermList) {
      Map postingList = _invertedIndex[t.term];
      if (postingList != null) {
        postingList.forEach((docName, tf) {
          _docTermList.add(
              TermClass(
                term: t.term,
                docName: docName,
                tf_raw: tf,
                tf_wt: _tf_wt(tf: tf),
                tf_idf: _tf_wt(tf: tf),
              ));
        });

      } else
        print('Term: ${t.term} dose\'nt exist in any document.\n\n');
    }
    _lncNormalize();
  }

  void _lncNormalize() {
    Map vectorValue = {}; // docName : vector value

    // calculate sum
    _docTermList.forEach((t) {
      if (!vectorValue.containsKey(t.docName))
        vectorValue[t.docName] = pow(t.tf_idf, 2);
      else
        vectorValue[t.docName] += pow(t.tf_idf, 2);
    });

    // calculate sqrt
    vectorValue.forEach((docName, value) {
      vectorValue[docName] = sqrt(value);
    });

    // save normal tf.idf
    _docTermList.forEach((t) {
      t.normal_tf_idf = t.tf_idf / vectorValue[t.docName];

      print('---------------------------');
      print('       ${t.docName}');
      print('---------------------------');
      print('term: ${t.term}\ntf: ${t.tf_raw}\ntf_wt: ${t.tf_wt}\ntf.idf: ${t.tf_idf}\nvector_value: ${vectorValue[t.docName]}\nnormal_tf.idf: ${t.normal_tf_idf}\n\n');
    });
  }

  Map _calculateScore() {
    Map score = {}; // docName : score
    _queryTermList.forEach((t) {
      _docTermList.forEach((d) {
        if (t.term == d.term) {
          if (!score.containsKey(d.docName))
            score[d.docName] = t.normal_tf_idf * d.normal_tf_idf;
          else
            score[d.docName] += t.normal_tf_idf * d.normal_tf_idf;
        }
      });
    });

    print('Documents score: $score\n\n');
    return score;
  }
}