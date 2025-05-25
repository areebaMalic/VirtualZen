import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthViewModel with ChangeNotifier{


  Timer? _timer;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String?  _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;


  String _email = '';
  String get email => _email;

  bool _isChecked = false;
  bool get isChecked => _isChecked;

  User? get currentUser => _firebaseAuth.currentUser;

  AuthViewModel() {
    _initialize(); // ✅ check on app start
  }

  Future<void> _initialize() async {
    // Give Firebase a moment to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }


  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void toggleCheckBoxValue(bool checkValue){
    _isChecked = checkValue;
    notifyListeners();
  }

  // ✅ PIN generator
  String _generatePIN() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<User?> signUpWithEmailPassword(String email, String password, String name) async {
    if (!EmailValidator.validate(email)) {
      setErrorMessage('Invalid email format.');
      return null;
    }

    setLoading(true);

    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        setEmail(email);

        final pin = _generatePIN();
        final fcmToken = await _getFcmTokenSafely();


        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'pin': pin,
          'isOnline': true,
          'createdAt': FieldValue.serverTimestamp(),
          if (fcmToken != null) 'fcmToken': fcmToken,
        });

        await sendVerificationEmail(); // 📧 send verification email
        setLoading(false);
        return user;
      /*  // 🚨 Sign out after sending verification email
        await _firebaseAuth.signOut();*/
      }
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message.toString());
      setLoading(false);
      return null;
    } catch (e) {
      setErrorMessage("Something went wrong. Please check your connection.");
      setLoading(false);
      return null;
    }
    return null;
  }

  Future<void> sendVerificationEmail()async {

    try{
      User? user =_firebaseAuth.currentUser;
      if(user !=null && !user.emailVerified){
        await user.sendEmailVerification();
        setErrorMessage('Verification email sent! please check your inbox');
      }else{
        setErrorMessage('User is already verified or not logged in');
      }
    } catch (e){
      setErrorMessage(e.toString());
    }
    notifyListeners();
  }

  Future<bool> checkEmailVerification(BuildContext context) async {
    await FirebaseAuth.instance.currentUser?.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }


  Future<User?> loginUserWithEmailPassword(String email, String password) async {
    setLoading(true);

    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await user.reload(); // ✅ Always reload to get latest status

        if (!user.emailVerified) {
          setErrorMessage('Please verify your email before logging in.');
          await _firebaseAuth.signOut(); // 🚫 Sign out unverified user
          setLoading(false);
          return null;
        }

        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': fcmToken,
            'isOnline': true,
          });
        }
      }

      setLoading(false);
      return user;

    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message.toString());
      setLoading(false);
      return null;
    } catch (e) {
      setErrorMessage("Something went wrong. Please check your connection.");
      setLoading(false);
      return null;
    }
  }


  Future<User?> signUpWithGoogle(String name) async {
    setLoading(true);
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          final pin = _generatePIN();

          final fcmToken = await _getFcmTokenSafely();


          await _firestore.collection('users').doc(user.uid).set({
            'name': name,
            'email': user.email,
            'pin': pin,
            'isOnline': true,
            'createdAt': FieldValue.serverTimestamp(),
            if (fcmToken != null) 'fcmToken': fcmToken,
          });
        }
      }

      return user;
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return null;
    }
  }

  Future<void> logoutUser()async {
    try{
      await  _firebaseAuth.signOut();
      _isEmailVerified = false;
      _email = '';
      notifyListeners();
    } catch (e){
      setErrorMessage(e.toString());
    }
  }


  Future<String?> _getFcmTokenSafely() async {
    try {
      return await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint("FCM Token error: $e");
      return null;
    }
  }




  Future<void> sendPasswordResetLink(String email) async{
    setLoading(true);
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      setLoading(false);

    }catch (e){
      setErrorMessage(e.toString());
      setLoading(false);
    }
  }

  Future<void> checkResetPassword(String newPassword , String confirmPassword) async {
    if (newPassword != confirmPassword) {
      setErrorMessage('Passwords do not match');
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setErrorMessage('Password cannot be empty');
      return;
    }
    setLoading(true);
    try{
      User? user = _firebaseAuth.currentUser; // Get the current user
      if (user != null) {
        await user.updatePassword(newPassword);
        setErrorMessage('Password updated successfully');

        setLoading(false);
      } else {
        setErrorMessage('User is not logged in');
        setLoading(false);
      }
    }on FirebaseException catch(e){
      setErrorMessage(e.message ?? 'An error occurred');
      setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut(BuildContext context) async {
    try {

      await _firebaseAuth.signOut();
      notifyListeners(); // 🔥 Important after sign out
    } catch (e) {
      // Handle any errors
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}