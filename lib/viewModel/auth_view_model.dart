import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthViewModel with ChangeNotifier{


  Timer? _timer;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String?  _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;


  String _email = '';
  String get email => _email;


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

  bool _isChecked = false;
  bool get isChecked => _isChecked;

  void toggleCheckBoxValue(bool checkValue){
    _isChecked = checkValue;
    notifyListeners();
  }

  Future<User?> signUpWithEmailPassword(String email , String password) async{

    if (!EmailValidator.validate(email)) {
      setErrorMessage('Invalid email format.');
      setLoading(false);
      return null;
    }

    setLoading(true);

    try{
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      setEmail(email);
      await sendVerificationEmail();
      setLoading(false);

      return userCredential.user;

    }on FirebaseAuthException catch(e){
      setErrorMessage(e.message.toString());
      setLoading(false);
      return null;
    }
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


  Future<User?> loginUserWithEmailPassword(String email , String password) async{
    setLoading(true);

    try{
      UserCredential userCredential=await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      setLoading(false);
      return userCredential.user;

    }on FirebaseAuthException catch(e){
      setErrorMessage(e.message.toString());
      setLoading(false);
      return null;
    }

  }

  Future<User? > signUpWithGoogle() async{
    setLoading(true);
    try{
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      setLoading(false);
      return userCredential.user;
    }catch(e){
      setErrorMessage(e.toString());
      setLoading(false);
    }
    return null;
  }

  Future<void> logoutUser()async {
    try{
      await  _firebaseAuth.signOut();
      _isEmailVerified = false;
      _user = null;
      _email = '';
      notifyListeners();
    } catch (e){
      setErrorMessage(e.toString());
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


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}