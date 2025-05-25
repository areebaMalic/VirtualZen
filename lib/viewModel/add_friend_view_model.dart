import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../model/user_model.dart';


class AddFriendViewModel extends ChangeNotifier {

  final _db = FirebaseFirestore.instance;

  final TextEditingController _pinController = TextEditingController();
  TextEditingController get  getPinController => _pinController;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  set errorMessage(String message) {
    _errorMessage = message;
    notifyListeners();

    if (message.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = '';
        notifyListeners();
      });
    }
  }


  Future<dynamic> sendRequest(String pin, UserModel currentUser) async {
    final query = await _db.collection('users').where('pin', isEqualTo: pin).get();

    if (query.docs.isEmpty) return 'invalid';

    final receiver = query.docs.first;
    final receiverId = receiver.id;

    if (receiverId == currentUser.id) return 'invalid';

    final alreadyAdded = await _db
        .collection('users')
        .doc(currentUser.id)
        .collection('friends')
        .doc(receiverId)
        .get();

    if (alreadyAdded.exists) return 'already_added';

    await _db
        .collection('users')
        .doc(receiverId)
        .collection('requests')
        .doc(currentUser.id)
        .set({
      'name': currentUser.name,
      'pin': currentUser.pin,
      'id': currentUser.id,
    });


    return true;
  }

}