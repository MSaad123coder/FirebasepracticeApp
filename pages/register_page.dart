// Import necessary packages for functionality
import 'dart:io'; // For handling files
import 'package:file_picker/file_picker.dart'; // To pick files from the device
import 'package:firebase_core/firebase_core.dart'; // Firebase initialization
import 'package:flutter/material.dart'; // Main package for Flutter apps
import 'package:flutter_application_1/services/firebase_service.dart'; // Firebase service for app
import 'package:get_it/get_it.dart'; // Dependency injection tool

// A stateful widget for user registration
class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Registerpage(); // Create and return the state object
  }
}

// The state object of RegisterPage
class _Registerpage extends State<RegisterPage> {
  // To store the device's height and width
  double? _deviceHeight, _deviceWidth;

  // GlobalKey is used to access and control the state of the form
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  // FirebaseService for user authentication
  FirebaseService? _firebaseService;

  // Variables to store user input for name, email, and password
  String? _name, _email, _password;

  // Variable to hold the user's profile image
  File? _image;

  // Initialize the FirebaseService when the state is created
  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  // The main build method for the registration page UI
  @override
  Widget build(BuildContext context) {
    // Get device dimensions
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    // Scaffold provides the structure for the app's screen
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth! * 0.05), // Add padding to the container
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Space items evenly
              children: [
                _titleWidget(), // App title
                _profileimageWidget(), // Profile image picker
                _registrationForm(), // Registration form
                _registerButton(), // Register button
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Registration form containing email, name, and password fields
  Widget _registrationForm() {
    return Container(
      height: _deviceHeight! * 0.30, // Takes 30% of the device's height
      child: Form(
        key: _registerFormKey, // Use the global key to manage form state
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Equal spacing between fields
          children: [
            _emailTextFeild(),
            _nameTextfeild(),
            _passwordTextFeild(),
          ],
        ),
      ),
    );
  }

  // Widget to handle profile image upload
  Widget _profileimageWidget() {
    // Display user's image or a placeholder if no image is chosen
    var _imageProvider = _image != null
        ? FileImage(_image!) // Show the picked image
        : const NetworkImage("https://i.pravatar.cc/300"); // Show placeholder

    return GestureDetector(
      onTap: () {
        FilePicker.platform.pickFiles(type: FileType.image).then((_result) {
          // Update the image when picked
          setState(() {
            _image = File(_result!.files.first.path!);
          });
        });
      },
      child: Container(
        height: _deviceHeight! * 0.15,
        width: _deviceWidth! * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: _imageProvider as ImageProvider,
          ),
        ),
      ),
    );
  }

  // Text field for user name input
  Widget _nameTextfeild() {
    return TextFormField(
      decoration: const InputDecoration(hintText: "Name"), // Input hint
      validator: (_value) => _value!.isNotEmpty
          ? null
          : "Please enter a name", // Validation for empty field
      onSaved: (_value) {
        setState(() {
          _name = _value;
        });
      },
    );
  }

  // Text field for user email input
  Widget _emailTextFeild() {
    return TextFormField(
      decoration: const InputDecoration(hintText: "Email..."),
      onSaved: (_value) {
        setState(() {
          _email = _value; // Save the email when form is submitted
        });
      },
      validator: (_value) {
        // Validate email format
        if (_value == null ||
            !_value.contains(
              RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
            )) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  // Text field for user password input
  Widget _passwordTextFeild() {
    return TextFormField(
      obscureText: true, // Hide text for passwords
      decoration: const InputDecoration(hintText: "Password..."),
      onSaved: (_value) {
        setState(() {
          _password = _value;
        });
      },
      validator: (_value) =>
          _value!.length > 6 ? null : "Password must be at least 6 characters",
    );
  }

  // Title widget displaying the app name
  Widget _titleWidget() {
    return const Text(
      "Finstagram",
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
    );
  }

  // Register button to submit form
  Widget _registerButton() {
    return MaterialButton(
      onPressed: _registerUser,
      minWidth: _deviceWidth! * 0.50, // Button width
      height: _deviceHeight! * 0.05, // Button height
      color: Colors.red, // Button color
      child: const Text(
        "Register",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  // Method to handle user registration
  void _registerUser() async {
    // Check if form is valid and image is picked
    if (_registerFormKey.currentState!.validate() && _image != null) {
      _registerFormKey.currentState!.save(); // Save form data
      var _result = await _firebaseService!.registerUserWithEmailAndPassword(
          _email!, _password!, _name!, _image!);

      // If registration succeeds, navigate to the previous page
      if (_result != null) {
        Navigator.pop(context);
      } else {
        // Show error message if registration fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }
}
