import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String? userKey;

  @HiveField(1)
  String? firstName;

  @HiveField(2)
  String? lastName;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? mobile;

  @HiveField(5)
  String? alternateNumber;

  @HiveField(6)
  String? dateOfBirth;

  @HiveField(7)
  String? gender;

  @HiveField(8)
  String? genderName;

  @HiveField(9)
  String? userCode;

  @HiveField(10)
  String? profileImage;

  @HiveField(11)
  String? localProfileImagePath;

  @HiveField(12)
  int? subscriptionStatus;

  @HiveField(13)
  bool isLoggedIn;

  @HiveField(14)
  DateTime? createdAt;

  @HiveField(15)
  DateTime? updatedAt;

  UserModel({
    this.userKey,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.alternateNumber,
    this.dateOfBirth,
    this.gender,
    this.genderName,
    this.userCode,
    this.profileImage,
    this.localProfileImagePath,
    this.subscriptionStatus,
    this.isLoggedIn = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  @override
  String toString() =>
      'UserModel(userKey: $userKey, email: $email, name: $fullName)';
}
