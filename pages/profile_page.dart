import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore to access data stored in the cloud
import 'package:firebase_core/firebase_core.dart'; // Import Firebase to initialize and work with Firebase services
import 'package:flutter/material.dart'; // Flutter framework for UI building
import 'package:flutter_application_1/services/firebase_service.dart'; // Import your custom Firebase service file to use app-specific logic
import 'package:get_it/get_it.dart'; // Package to implement service locator pattern for dependency injection

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState(); // Link this widget to its state class
  }
}

class _ProfilePageState extends State<ProfilePage> {
  double? _deviceHeight,
      _deviceWidth; // Variables to store the height and width of the device's screen
  FirebaseService?
      firebaseService; // A FirebaseService instance to handle app-specific Firebase operations

  @override
  void initState() {
    super
        .initState(); // Call the parent class’ initState method (important for proper lifecycle handling)
    firebaseService = GetIt.instance.get<
        FirebaseService>(); // Use GetIt to fetch the registered FirebaseService instance
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context)
        .size
        .height; // Fetch the screen height dynamically
    _deviceWidth =
        MediaQuery.of(context).size.width; // Fetch the screen width dynamically
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _deviceWidth! *
            0.05, // Set horizontal padding based on 5% of screen width
        vertical: _deviceHeight! *
            0.02, // Set vertical padding based on 2% of screen height
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.max, // Take maximum available height for the column
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space out children evenly
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center the column content horizontally
        children: [
          _profileImage(),
          _postsgridview()
        ], // Include profile image and posts grid view widgets
      ),
      color: Colors.blueGrey, // Background color for the container
    );
  }

  Widget _profileImage() {
    return Container(
      margin: EdgeInsets.only(
          bottom:
              _deviceHeight! * 0.02), // Add bottom margin (2% of screen height)
      height: _deviceHeight! *
          0.15, // Set height of the profile image container (15% of screen height)
      width: _deviceWidth! *
          0.15, // Set width of the profile image container (15% of screen width)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            100), // Make the image circular by setting a high border radius
        image: DecorationImage(
          fit: BoxFit.cover, // Scale the image to cover the box entirely
          image: NetworkImage(firebaseService!.currentUser![
              "image"]), // Fetch and display the user's profile image from Firebase
        ),
      ),
    );
  }

  Widget _postsgridview() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: firebaseService!
            .getPostsForUser(), // Listen to the real-time Firestore stream for the user's posts
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Check if snapshot has any data
            List _Posts = snapshot.data!.docs
                .map((e) => e.data())
                .toList(); // Convert Firestore documents to a list
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Create a grid with 3 columns
                crossAxisSpacing: 4.0, // Space between columns
                mainAxisSpacing: 4.0, // Space between rows
              ),
              itemCount: _Posts.length, // Number of posts to show in the grid
              itemBuilder: (context, index) {
                var post = _Posts[index]; // Get individual post data
                return Image.network(
                  post["image"], // Display the image for each post
                  fit: BoxFit.cover, // Scale the image to cover each grid item
                );
              },
            );
          } else {
            // If no data is found or still loading
            return const Center(
              child: CircularProgressIndicator(
                // Show a loading spinner
                color: Colors.red, // Spinner color
              ),
            );
          }
        },
      ),
    );
  }
}
