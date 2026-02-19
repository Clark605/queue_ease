import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

/// DI module that provides Firebase and Google Sign-In singletons.
@module
abstract class AuthModule {
  /// Provides [FirebaseAuth.instance] for injection.
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  /// Provides [FirebaseFirestore.instance] for injection.
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Provides the [GoogleSignIn] singleton for injection.
  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn.instance;
}
