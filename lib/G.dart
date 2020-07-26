import 'dart:io';

import 'package:path_provider/path_provider.dart';

String documentPath;
String invertedPath;

void createDirectory() async{
  final Directory mainPath = await getExternalStorageDirectory();

  // create directory path
  documentPath = '${mainPath.path}/QSearch/Documents';
  await Directory(documentPath).create(recursive: true);
  print('\nDocument Path: $documentPath');

  // create posting list path
  invertedPath = '${mainPath.path}/QSearch/Inverted index';
  await Directory(invertedPath).create(recursive: true);
  print('Inverted index Path: $invertedPath\n');

}

List<String> findTerms({String content}) {
  // first separate by space then remove all .،,'"()?!؟:/\ from term if anything left
  // considers as a term
  List<String> terms = new List<String>();

  List<String> spaceSeparated = content.split(' ');
  spaceSeparated.forEach((term) {

    if (term.contains('.'))
      term = term.replaceAll('.', '');
    if (term.contains('،'))
      term = term.replaceAll('،', '');
    if (term.contains(','))
      term = term.replaceAll(',', '');
    if (term.contains('\''))
      term = term.replaceAll('\'', '');
    if (term.contains('\"'))
      term = term.replaceAll('\"', '');
    if (term.contains('\('))
      term = term.replaceAll('\(', '');
    if (term.contains('\)'))
      term = term.replaceAll('\)', '');
    if (term.contains('?'))
      term = term.replaceAll('?', '');
    if (term.contains('!'))
      term = term.replaceAll('!', '');
    if (term.contains('؟'))
      term = term.replaceAll('؟', '');
    if (term.contains(':'))
      term = term.replaceAll(':', '');
    if (term.contains('/'))
      term = term.replaceAll('/', '');
    if (term.contains('\\'))
      term = term.replaceAll('\\', '');

    if (term.length > 0)
      terms.add(term);
  });
  return terms;
}