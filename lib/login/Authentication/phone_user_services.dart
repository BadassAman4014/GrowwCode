//for all firebase related services for user
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growwcode/login/Authentication/phone_user_model.dart';

class UserServices{
  String collection = 'users';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create new user
  Future<void>createUserData(Map<String,dynamic>values)async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).set(values);
  }

//update user data
  Future<void>updateUserData(Map<String,dynamic>values)async{
    String id = values ['id'];
    await _firestore.collection(collection).doc(id).update(values);
  }

//get user data by UserID
  Future<void>getUserbyId(String id)async {
    await _firestore.collection(collection).doc(id).get()
        .then((doc) {
      if (doc.data() == null) {
        return null;
      }
      return UserModel.fromSnapshot(doc);
    });
  }
}
