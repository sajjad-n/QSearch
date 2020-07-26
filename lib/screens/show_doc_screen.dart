import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowDocScreen extends StatelessWidget {

  final String docName, content;

  ShowDocScreen({this.content, this.docName});

  @override
  Widget build(BuildContext context) {
    var _topPadding = MediaQuery.of(context).padding.top + 10;
    var _screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xff383838),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: _topPadding),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/search_background.png'),
                  fit: BoxFit.cover
              )
          ),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Text(
                docName,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: _screenSize.width,
                height: 1,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                content,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

}