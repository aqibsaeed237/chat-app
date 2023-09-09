//Packages
import 'package:chatapp/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_services.dart';
import '../services/navigation.service.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _databaseService.updateUserLastSeenTime(user.uid.toString());
        _databaseService.getUser(user.uid).then((snapshot) {
          Map<String, dynamic> userData =
              snapshot.data()! as Map<String, dynamic>;

          user = ChatUser.fromJSON(
            {
              "uid": user!.uid as Stream,
              "name": userData["name"],
              "email": userData["email"],
              "last_active": userData["last_active"],
              "image": userData["image"],
            },
          ) as User?;
        });
      } else {}
    });
  }

  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException {
      print('Error login User');
    } catch (e) {
      print(e);
    }
  }

  Future<String?> registerUsingEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException {
      print("Error registering user");
    } catch (e) {
      print(e);
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
