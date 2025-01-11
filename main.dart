import 'dart:ui';
// Provides tools for graphics and windowing, used for rendering your app.

import 'package:flutter/material.dart';
// The core Flutter library used to create visual components like buttons, text fields, etc.

import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_pages.dart';
import 'package:flutter_application_1/pages/register_page.dart';
// These lines bring in the different screens (pages) of your app:
// HomePage, LoginPage, and RegisterPage.

import 'package:firebase_core/firebase_core.dart';
// This library is needed to set up and use Firebase services (e.g., authentication, database).

import 'package:flutter_application_1/services/firebase_service.dart';
// This file likely contains custom code to help interact with Firebase.

import 'package:get_it/get_it.dart';
// GetIt is used for dependency injection. It helps in managing objects and their lifetimes easily.

void main() async {
  await Firebase.initializeApp;
  // Initializes Firebase so your app can connect to Firebase services.

  GetIt.instance.registerSingleton<FirebaseService>(
    FirebaseService(),
  );
  // Registers a single instance of FirebaseService, so you can use it anywhere in the app without creating multiple instances.

  WidgetsFlutterBinding.ensureInitialized;
  // Makes sure all widgets are properly set up before the app starts.

  runApp(const MyApp());
  // Starts your app by calling the MyApp class, which is the root widget.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // The `MyApp` class represents your whole application. It’s a widget, and Flutter apps are made up of widgets.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // `MaterialApp` is a predefined class that helps set up your app with common UI features like themes and navigation.

      title: 'Feinstagram',
      // The title of your app, shown in debugging tools.

      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // Defines the overall look of your app. Here, the main color of your app is red.

      initialRoute: 'login',
      // Sets the starting screen of your app. In this case, the login page.

      routes: {
        // Maps route names to the actual screens they represent in your app.
        'register': (context) => RegisterPage(),
        // The 'register' route takes the user to the RegisterPage.

        'login': (context) => LoginPage(),
        // The 'login' route takes the user to the LoginPage.

        'home': (context) => HomePage(),
        // The 'home' route takes the user to the HomePage.
      },
    );
  }
}
