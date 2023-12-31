import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenify/model/wallet_model.dart';
import 'package:greenify/utils/uuid.dart';

class FireAuth {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static Future<User?> registerUser(
      {required String email,
      required String password,
      required String name}) async {
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await sendDataToCollection(user: user, name: name);
      await refreshUser();
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      throw Exception('Error occured!');
    }
    return null;
  }

  static Future<User?> signInWithEmailPassword(
      {required String email, required String password}) async {
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      await refreshUser();
      return user;
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          throw Exception('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          throw Exception('Wrong password provided for that user.');
        }
      }
      throw Exception('Error occurred!');
    }
  }

  static Future<User?> signInWithGoogle() async {
    try {
      List<String> scopes = [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ];

      GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: scopes,
        clientId: dotenv.env['GOOGLE_CLIENT_ID'],
      ).signIn();
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      User? user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      final isExist = users.doc(user!.uid).get().then((doc) => doc.exists);
      if (await isExist) {
        refreshUser();
        return user;
      } else {
        await sendDataToCollection(user: user);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'The account already exists with a different credential.');
      } else if (e.code == 'invalid-credential') {
        throw Exception(
            'Error occured while accessing credentials. Try again.');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static void signOut() {
    auth.signOut();
  }

  static User? getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  static Future<void> refreshUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user!.reload();
  }

  static Future<void> sendDataToCollection({User? user, String? name}) async {
    final gardenId = UUIDUtils.generateUUID();
    final potId = UUIDUtils.generateUUID();
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    try {
      await users.doc(user!.uid).set({
        'name': user.displayName ?? name,
        'email': user.email,
        'image_url': user.photoURL,
        'user_id': user.uid,
        "exp": 0,
        "level": 1,
        "photo_frame": "default",
        "title": "default",
        "wallet": WalletModel(value: 0).toMap(),
        "created_at": DateTime.now(),
        "updated_at": DateTime.now(),
      });
      await users.doc(user.uid).collection('gardens').doc(gardenId).set({
        "name": "My Garden",
        "background_url":
            "https://akcdn.detik.net.id/visual/2015/03/05/08834c51-d4e2-418f-933d-73387f82444c_169.jpg?w=650",
        "created_at": DateTime.now(),
        "updated_at": DateTime.now(),
      });

      // await users
      //     .doc(user.uid)
      //     .collection('gardens')
      //     .doc(gardenId)
      //     .collection('pots')
      //     .doc(potId)
      //     .set({
      //   "status": "empty",
      //   "position_index": 0,
      //   "plant": {
      //     "name": "default",
      //     "image": "https://cdn-icons-png.flaticon.com/512/5225/5225392.png",
      //     "category": "Sayur",
      //     "height": 0.0,
      //     "status": "healthy",
      //     "timeID": 1,
      //     "watering_schedule": "1",
      //     "watering_time": "01:00",
      //     "description": "default",
      //     "created_at": DateTime.now(),
      //     "updated_at": DateTime.now(),
      //   },
      // });
    } catch (e) {
      throw Exception('Error occured!');
    }
  }
}
