// Import necessary Flutter and Firebase libraries
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore functionality
import 'package:firebase_core/firebase_core.dart'; // Firebase initialization
import 'package:flutter/material.dart'; // Material UI components
import 'package:flutter_application_1/services/firebase_service.dart'; // Firebase service (custom)
import 'package:get_it/get_it.dart'; // Dependency Injection library (GetIt)

class FeedPage extends StatefulWidget {
  // Stateful widget to maintain state of FeedPage
  @override
  State<StatefulWidget> createState() {
    return _FeedPageState();
  }
}

class _FeedPageState extends State<FeedPage> {
  // Variables to store device width and height
  double? _deviceHeight, _deviceWidth;

  // Variable to hold the instance of FirebaseService (dependency injection)
  FirebaseService? _firebaseservice;

  // Init method to retrieve the FirebaseService instance from GetIt
  @override
  void initState() {
    super.initState();
    _firebaseservice = GetIt.instance.get<FirebaseService>();
  }

  // Builds the widget tree for the FeedPage
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height; // Get device height
    _deviceWidth = MediaQuery.of(context).size.width; // Get device width

    // Return container holding a list view of posts
    return Container(
      height: _deviceHeight, // Full height of device
      width: _deviceWidth, // Full width of device
      child: _postslistview(), // Calls the method to get posts
    );
  }

  // Builds the list of posts using a StreamBuilder
  Widget _postslistview() {
    // StreamBuilder listens for the real-time Firestore data changes
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseservice!
          .getLatestPosts(), // Firebase service function to get posts
      builder: (BuildContext _context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          // If snapshot has data, map it to a list of posts
          List _posts = snapshot.data!.docs
              .map((e) => e.data())
              .toList(); // Fix here: typo in 'tolist()' method (should be 'toList()')

          // ListView to display each post in a container
          return ListView.builder(
            itemCount: _posts.length, // Count of posts
            itemBuilder: (BuildContext context, int index) {
              Map _post = _posts[index]; // Access individual post data
              String url = _post[
                  'imageUrl']; // Get image URL from the post (change '_post['image']' to '_post['imageUrl']')

              // Display the post with the image as background
              return Container(
                height: _deviceHeight! * 0.30, // Set the height of each post
                margin: EdgeInsets.symmetric(
                  vertical:
                      _deviceHeight! * 0.01, // Margin for vertical spacing
                  horizontal:
                      _deviceWidth! * 0.05, // Margin for horizontal spacing
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      url, // Correct variable name for the image URL
                    ),
                    fit: BoxFit
                        .cover, // Ensure the image covers the entire container
                  ),
                ),
              );
            },
          );
        } else {
          // Show a progress indicator while data is loading
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
