import 'package:cloud_firestore/cloud_firestore.dart'; // Enables Firebase Firestore functionality.
import 'package:firebase_auth/firebase_auth.dart'; // Provides Firebase Authentication services.
import 'package:firebase_storage/firebase_storage.dart'; // Allows uploading and accessing files in Firebase Storage.
import 'dart:io'; // Provides functionality to work with files.
import 'package:path/path.dart'
    as p; // Utility package for handling and parsing file paths.

// Constants for Firestore collection names
final String USER_COLLECTION = 'users'; // Firestore collection for user data.
final String POSTS_COLLECTION = 'posts'; // Firestore collection for user posts.

// Class to handle Firebase-related services
class FirebaseService {
  // Firebase service instances
  FirebaseAuth _auth =
      FirebaseAuth.instance; // Instance for user authentication.
  FirebaseStorage _storage =
      FirebaseStorage.instance; // Instance for file storage operations.
  FirebaseFirestore _db =
      FirebaseFirestore.instance; // Instance for Firestore database operations.
  Map? currentUser; // Stores the current user's data as a Map.

  FirebaseService(); // Constructor for initializing the service.

  // Function to register a new user
  Future<bool> registerUser({
    required String name, // User's name.
    required String email, // User's email.
    required String password, // User's password.
    required File image, // User's profile image.
  }) async {
    try {
      // Create a new user in Firebase Authentication.
      UserCredential _userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the current user's unique ID (uid).
      String uid = _auth.currentUser!.uid;

      // Generate a unique filename for the image using timestamp.
      String _fileName = Timestamp.now().microsecondsSinceEpoch.toString() +
          p.extension(image.path);

      // Upload the image to Firebase Storage in the "userImages" folder.
      UploadTask uploadTask =
          _storage.ref().child('userImages/$uid').putFile(image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Retrieve the image's download URL after a successful upload.
      String downloadUrl;
      if (snapshot.state == TaskState.success) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        throw Exception(
            'Image upload failed'); // Throw an error if the upload fails.
      }

      // Save the user's data (name, email, image URL) in Firestore under the "users" collection.
      await _db.collection(USER_COLLECTION).doc(uid).set({
        'name': name,
        'email': email,
        'imageUrl': downloadUrl,
      });

      // Fetch and store the current user's data for easy access.
      currentUser = await getUserData(uid: uid);
    } catch (e) {
      // Handle and log any errors that occur.
      print(e);
      return false; // Return false to indicate registration failure.
    }
    return true; // Return true if registration is successful.
  }

  // Function to log in an existing user
  Future<bool> loginUser({
    required String email, // User's email.
    required String Password, // User's password.
  }) async {
    try {
      // Authenticate the user using their email and password.
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: Password,
      );

      // If the user is successfully logged in, fetch their data.
      if (_userCredential.user != null) {
        currentUser = await getUserData(uid: _userCredential.user!.uid);
        return _userCredential.user !=
            null; // Return true if login is successful.
      }
    } catch (e) {
      // Log any errors and return false for login failure.
      print(e);
      return false;
    }
    return false; // Default case: return false if login fails.
  }

  // Function to retrieve user data from Firestore
  Future<Map> getUserData({required String uid}) async {
    // Fetch the document for the given user ID.
    DocumentSnapshot _doc =
        await _db.collection(USER_COLLECTION).doc(uid).get();
    return _doc.data() as Map; // Return the data as a Map.
  }

  // Function to post an image with a description
  Future<bool> postImage(File _image, {required String description}) async {
    try {
      // Get the current user's unique ID.
      String uid = _auth.currentUser!.uid;

      // Generate a unique filename for the image using timestamp.
      String _fileName = Timestamp.now().microsecondsSinceEpoch.toString() +
          p.extension(_image.path);

      // Upload the image to Firebase Storage in the "postImages" folder.
      UploadTask uploadTask =
          _storage.ref().child('postImages/$uid/$_fileName').putFile(_image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      // Retrieve the download URL for the uploaded image.
      String downloadUrl;
      if (snapshot.state == TaskState.success) {
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else {
        throw Exception(
            'Image upload failed'); // Throw an error if the upload fails.
      }

      // Save post details (user ID, image URL, description, timestamp) to Firestore.
      await _db.collection('posts').add({
        'uid': uid,
        'imageUrl': downloadUrl,
        'description': description,
        'timestamp': Timestamp.now(),
      });

      return true; // Return true if posting is successful.
    } catch (e) {
      // Log any errors and return false for failure.
      print(e);
      return false;
    }
  }

  // Stream to get posts for the current user from Firestore
  Stream<QuerySnapshot> getPostsForUser() {
    String _userId = _auth.currentUser!.uid; // Get the current user's ID.
    return _db
        .collection(POSTS_COLLECTION)
        .where('userID', isEqualTo: _userId)
        .snapshots(); // Return real-time updates for the user's posts.
  }

  // Stream to get the latest posts
  Stream<QuerySnapshot> getLatestPosts() {
    return _db
        .collection(POSTS_COLLECTION)
        .orderBy('timestamp', descending: true)
        .snapshots(); // Return posts ordered by timestamp, most recent first.
  }

  // Function to log out the current user
  Future<void> logout() async {
    await _auth.signOut(); // Sign out the user from Firebase.
  }
}
