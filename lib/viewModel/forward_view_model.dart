import 'package:flutter/material.dart';

class ForwardViewModel extends ChangeNotifier {
  final Set<String> _selectedFriendIds = {};

  Set<String> get selectedFriendIds => _selectedFriendIds;

  void toggleFriendSelection(String friendId) {
    if (_selectedFriendIds.contains(friendId)) {
      _selectedFriendIds.remove(friendId);
    } else {
      _selectedFriendIds.add(friendId);
    }
    notifyListeners();
  }

  void clearSelections() {
    _selectedFriendIds.clear();
    notifyListeners();
  }
}