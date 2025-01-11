import 'package:flutter/material.dart';
// The core Flutter library used for building your app's user interface.

import 'package:flutter_application_1/services/firebase_service.dart';
// Imports your custom Firebase service class to handle login functionality.

import 'package:get_it/get_it.dart';
// A library for dependency injection, making it easier to manage FirebaseService throughout the app.

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
    // Creates and returns an instance of `_LoginPageState`, which manages the state for this page.
  }
}

class _LoginPageState extends State<LoginPage> {
  double? _deviceHeight, _deviceWidth;
  // Variables to store the device's height and width.

  FirebaseService? _firebaseService;
  // A reference to the FirebaseService to handle user authentication.

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  // A global key used to identify and validate the login form.

  String? _email;
  // Variable to store the email entered by the user.

  String? _password;
  // Variable to store the password entered by the user.

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
    // Initializes the FirebaseService using the GetIt instance.
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    // Captures the screen's dimensions to calculate dynamic sizes for widgets.

    return Scaffold(
      // A basic visual structure for your app.
      body: SafeArea(
        // Ensures your UI avoids areas like the status bar and notches.
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.05),
          // Adds padding on the left and right of the container.

          child: Center(
            // Aligns child widgets to the center of the screen.
            child: Column(
              // Displays widgets vertically.
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // Distributes widgets evenly with space around them.

              mainAxisSize: MainAxisSize.max,
              // Expands the column to its maximum height.

              crossAxisAlignment: CrossAxisAlignment.center,
              // Aligns child widgets in the center horizontally.

              children: [
                _titleWidget(),
                // Displays the title of the app.

                _Loginbutton(),
                // Displays the login button.

                _loginForm(),
                // Displays the form with email and password fields.

                _registerpagelink(),
                // Displays a link to the registration page.
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return const Text(
      "Feinstagram",
      // Displays the app's title as "Feinstagram".

      style: TextStyle(
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.w700,
      ),
      // Sets the title text color, size, and thickness.
    );
  }

  Widget _loginForm() {
    return Container(
      height: _deviceHeight! * 0.20,
      // Sets the height of the form to 20% of the screen's height.

      child: Form(
        key: _loginFormKey,
        // Binds this form to the `_loginFormKey` for validation and saving.

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // Adds space around the email and password fields.

          crossAxisAlignment: CrossAxisAlignment.center,
          // Aligns fields to the center horizontally.

          mainAxisSize: MainAxisSize.max,
          // Expands the column to the maximum height available.

          children: [
            _emailTextFeild(),
            // Displays the email input field.

            _passwordTextFeild(),
            // Displays the password input field.
          ],
        ),
      ),
    );
  }

  Widget _emailTextFeild() {
    return TextFormField(
      decoration: const InputDecoration(hintText: "Email..."),
      // Provides a hint inside the text field saying "Email...".

      onSaved: (_value) {
        setState(() {
          _email = _value;
          // Saves the entered email to `_email` when the form is submitted.
        });
      },

      validator: (_value) {
        // Checks if the entered email is valid.
        if (_value == null ||
            !_value.contains(
              RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
            )) {
          return 'Please enter a valid email address';
          // Shows an error if the email is invalid.
        }
        return null;
        // Returns no error if the email is valid.
      },
    );
  }

  Widget _passwordTextFeild() {
    return TextFormField(
      obscureText: true,
      // Hides the text entered (e.g., displays dots or asterisks) for privacy.

      decoration: const InputDecoration(hintText: "password..."),
      // Provides a hint inside the text field saying "password...".

      onSaved: (_value) {
        setState(() {
          _password = _value;
          // Saves the entered password to `_password` when the form is submitted.
        });
      },

      validator: (_value) =>
          _value!.length > 6 ? null : "Please Enter A Valid Password",
      // Validates that the password is more than 6 characters.
    );
  }

  Widget _Loginbutton() {
    return MaterialButton(
      onPressed: _loginUser,
      // When pressed, the `_loginUser` function is called.

      minWidth: _deviceWidth! * 0.70,
      height: _deviceHeight! * 0.06,
      // Sets the button's width and height dynamically.

      color: Colors.red,
      // Sets the button's color to red.

      child: const Text(
        "Login",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
        // Styles the button's text to be white, large, and bold.
      ),
    );
  }

  Widget _registerpagelink() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, 'register'),
      // When tapped, navigates to the "register" screen.

      child: const Text(
        "Dont Have An Account",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        // Styles the link to be blue and bold.
      ),
    );
  }

  void _loginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      // Checks if the form's fields are valid.

      _loginFormKey.currentState!.save();
      // Saves the data entered in the form.

      bool _result = await _firebaseService!
          .loginUser(email: _email!, Password: _password!);
      // Calls the `loginUser` method in FirebaseService to attempt logging in.

      if (_result) {
        // If login succeeds:
        Navigator.pushReplacementNamed(context, 'home');
        // Navigate to the home screen and remove the login screen from the stack.
      } else {
        // If login fails:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
          // Shows a popup message saying the login failed.
        );
      }
    }
  }
}
