import 'dart:io'; // This allows us to work with files on the device.

import 'package:file_picker/file_picker.dart'; // A package to let users pick files, like images, from their device.
import 'package:firebase_core/firebase_core.dart'; // Firebase core package to connect the app to Firebase.
import 'package:flutter_application_1/services/firebase_service.dart'; // Importing a service to handle Firebase-related tasks (like uploading images).
import 'package:flutter/material.dart'; // Flutter's main library to build user interfaces.
import 'package:flutter_application_1/pages/feed_page.dart'; // Importing the page that shows the app's feed (e.g., posts).
import 'package:flutter_application_1/pages/profile_page.dart'; // Importing the user's profile page.
import 'package:get_it/get_it.dart'; // A package to manage single instances of services (Dependency Injection).

class HomePage extends StatefulWidget {
  // HomePage is where users land after logging in. It can change dynamically.
  @override
  State<StatefulWidget> createState() {
    return _HomePageState(); // Tells Flutter to use the _HomePageState for this widget.
  }
}

class _HomePageState extends State<HomePage> {
  FirebaseService?
      _firebaseService; // Will be used to handle Firebase operations, like logging out or posting images.
  int _currentPage =
      0; // Tracks which page (feed or profile) the user is on. Starts with the feed (0).

  // A list of pages the user can switch between: FeedPage and ProfilePage.
  final List<Widget> _pages = [
    FeedPage(), // Page for viewing posts.
    ProfilePage(), // Page for viewing the user profile.
  ];

  @override
  void initState() {
    // Called when the page is first loaded.
    super.initState(); // Ensures the parent class does its setup first.
    _firebaseService = GetIt.instance.get<
        FirebaseService>(); // Fetches the FirebaseService instance for use.
  }

  @override
  Widget build(BuildContext context) {
    // Builds the user interface for this page.
    return Scaffold(
      appBar: AppBar(
        // Top bar of the app.
        title:
            const Text("Finstagram"), // Sets the app's title to "Finstagram".
        actions: [
          // Items in the top-right corner of the app bar.
          GestureDetector(
            // Detects when the user taps the camera icon.
            onTap:
                _postImage, // Calls the function to let the user upload a picture.
            child: const Icon(Icons.add_a_photo), // Camera icon.
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0), // Adds space around the logout icon.
            child: GestureDetector(
              // Detects a tap on the logout icon.
              onTap: () async {
                // When the logout icon is tapped:
                await _firebaseService!
                    .logout(); // Logs the user out of Firebase.
                Navigator.popAndPushNamed(
                    context, 'login'); // Sends the user back to the login page.
              },
              child: const Icon(Icons.logout), // Logout icon.
            ),
          )
        ],
      ),
      bottomNavigationBar:
          _bottomNavigationbar(), // Displays the navigation bar at the bottom.
      body: _pages[
          _currentPage], // Shows the content of the selected page (feed or profile).
    );
  }

  Widget _bottomNavigationbar() {
    // Builds the navigation bar at the bottom of the screen.
    return BottomNavigationBar(
      currentIndex:
          _currentPage, // Highlights the current page (feed or profile).
      onTap: (_index) {
        // When the user taps a navigation button:
        setState(() {
          _currentPage = _index; // Updates the page index and refreshes the UI.
        });
      },
      items: const [
        BottomNavigationBarItem(
          label: 'Feed', // Label for the feed page.
          icon: Icon(
            Icons.feed, // Feed icon.
          ),
        ),
        BottomNavigationBarItem(
          label: 'Profile', // Label for the profile page.
          icon: Icon(
            Icons.person, // Profile icon.
          ),
        ),
      ],
    );
  }

  void _postImage() async {
    // Lets the user select and upload an image.
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image); // Opens a file picker for images.
    if (result != null) {
      // If the user selects a file:
      PlatformFile file = result.files.first; // Get the selected file details.
      print(
          'Picked file: ${file.name}'); // Print the name of the selected file to the console.
      var _image = file.path; // Get the file path.
      await _firebaseService!.postImage(
        _image as File, // Send the selected image to Firebase for upload.
        description:
            'Image description', // An optional description for the image.
      );
    } else {
      // If the user cancels the file picker:
      print('No file selected'); // Inform that no file was selected.
    }
  }
}
