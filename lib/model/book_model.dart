import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greenify/model/user_model.dart';
import 'package:greenify/services/users_service.dart';

class BookModel {
  String? id;
  String imageUrl;
  String title;
  String category;
  String content;
  String? userID;
  UserModel? user;
  String? createdAt;
  String? updatedAt;

  BookModel({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.content,
  });

  BookModel.fromQuery(DocumentSnapshot<Object?> data)
      : id = data.id,
        imageUrl = data['image_url'],
        title = data['title'],
        category = data['category'],
        content = data['content'],
        userID = data['user_id'],
        createdAt = data['created_at'].toString(),
        updatedAt = data['updated_at'].toString();

  Future<void> getUserModel() async {
    print("timestamp $createdAt");
    user = await UsersServices().getUserById(id: userID!);
  }
}
