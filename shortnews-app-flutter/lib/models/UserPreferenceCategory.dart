import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ModelKeys.dart';

class UserPreferenceCategory {
  String? categoryId;
  String? userId;
  String? categoryName;

  UserPreferenceCategory({
    this.categoryId,
    this.userId,
    this.categoryName,
  });

  factory UserPreferenceCategory.fromJson(Map<String, dynamic> json) {
    return UserPreferenceCategory(
      categoryId: json[UserPreferenceCategoryKeys.categoryId],
      userId: json[UserPreferenceCategoryKeys.userId],
      categoryName: json[UserPreferenceCategoryKeys.categoryName]
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[UserPreferenceCategoryKeys.categoryId] = this.categoryId;
    data[UserPreferenceCategoryKeys.userId] = this.userId;
    data[UserPreferenceCategoryKeys.categoryName] = this.categoryName;
    return data;
  }
}
