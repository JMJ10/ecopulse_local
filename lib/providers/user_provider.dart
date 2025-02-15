import 'package:ecopulse_local/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier{
  User _user = User(
    id: '',
    name: '',
    email: '',
    password: '',
    location: '',
    token: '',
    );

    User get user => _user;
    void setUser(String user){
      if (user.isEmpty){
        _user = User(
        id: '',
        name: '',
        email: '',
        password: '',
        location: '',
        token: '',
        );
      }
      else{
      _user = User.fromJson(user);
      }  
      notifyListeners();
    }

    void setUserFromModel(User user){
        _user=user;
        notifyListeners();
    }
}