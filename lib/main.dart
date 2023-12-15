import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'src/screen/Home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(236, 240, 241, 1),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Color.fromRGBO(236, 240, 241, 1)),
        // Supprimez useMaterial3 car cela pourrait ne pas être nécessaire
      ),
      routes: {
        'Home': (context) => Home(),
      },
      home: const Splashscreen(),
    );
  }
}

class Splashscreen extends StatelessWidget {
  const Splashscreen();

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      nextScreen: Home(),
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/temperature.png',
            height: 250, // Ajustez la taille en fonction de vos besoins
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(51, 51, 51, 1),
      duration: 4000,
      splashIconSize: 250,
      splashTransition: SplashTransition.slideTransition,
    );
  }
}
