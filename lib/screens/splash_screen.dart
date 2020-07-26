import 'package:flutter/material.dart';
import 'package:qsearch/screens/search_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xff383838),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash_background.png'),
              fit: BoxFit.cover
            )
          ),
          child: Center(
            child: FadeTransition(
                opacity: _fadeAnim,
                child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 250,
                    height: 150
                )
            ),
          ),
        )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  void _initAnimations() {
    _animController = new AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..forward();
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(_animController)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(seconds: 2), () {
            _navigateToSearchScreen();
          });
        }
      });
  }

  void _navigateToSearchScreen() {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            })
    );
  }
}
