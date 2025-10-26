import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract interface class AuthDataSource{
  Future<User?> signIn();

  Future<bool> signOut();

  User? getCurrentUser();
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  const AuthDataSourceImpl(this.auth, this.googleSignIn);

  @override
  Future<User?> signIn() async{
    try {
      // await googleSignIn.initialize();  you have to initialize in init dependencies

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        return null;
      }
      // Obtain the auth details from the authenticated user.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential for Firebase using the tokens from Google.
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential.
      final UserCredential userCredential = await auth.signInWithCredential(credential);

      // // Return the User from the UserCredential.
      // print('Successfully signed in with Google: ${userCredential.user?.displayName}');
      // print('Successfully signed in with Google: ${userCredential.user?.email}');
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> signOut() async{
    try {
      await googleSignIn.signOut();
      await auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the current signed-in Firebase user.
  @override
  User? getCurrentUser() {
    return auth.currentUser;
  }

  Stream<User?> get authStateChanges => auth.authStateChanges();
}