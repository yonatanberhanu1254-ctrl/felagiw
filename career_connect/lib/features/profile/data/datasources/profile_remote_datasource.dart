import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getStudentProfile(String uid);
  Future<void> updateStudentProfile(UserModel user);
  Future<String> uploadProfileImage({required String uid, required File imageFile});
  Future<String> uploadResume({required String uid, required File resumeFile});
  Future<EmployerModel> getEmployerProfile(String uid);
  Future<void> updateEmployerProfile(EmployerModel employer);
  Future<String> uploadCompanyLogo({required String uid, required File imageFile});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Future<UserModel> getStudentProfile(String uid) async {
    try {
      final doc = await _firestore.collection(AppConfig.usersCollection).doc(uid).get();
      if (!doc.exists) throw const NotFoundException('Profile not found.');
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateStudentProfile(UserModel user) async {
    try {
      final data = user.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(AppConfig.usersCollection).doc(user.uid).update(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage({required String uid, required File imageFile}) async {
    try {
      final ref = _storage.ref('${AppConfig.profileImagesPath}/$uid.jpg');
      final task = await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw StorageException(e.toString());
    }
  }

  @override
  Future<String> uploadResume({required String uid, required File resumeFile}) async {
    try {
      final ext = resumeFile.path.split('.').last;
      final ref = _storage.ref('${AppConfig.resumesPath}/$uid.$ext');
      final task = await ref.putFile(resumeFile);
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw StorageException(e.toString());
    }
  }

  @override
  Future<EmployerModel> getEmployerProfile(String uid) async {
    try {
      final doc = await _firestore.collection(AppConfig.employersCollection).doc(uid).get();
      if (!doc.exists) throw const NotFoundException('Employer profile not found.');
      return EmployerModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateEmployerProfile(EmployerModel employer) async {
    try {
      final data = employer.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(AppConfig.employersCollection).doc(employer.uid).update(data);
      // Also update shared users collection
      await _firestore.collection(AppConfig.usersCollection).doc(employer.uid).update({
        'companyName': employer.companyName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadCompanyLogo({required String uid, required File imageFile}) async {
    try {
      final ref = _storage.ref('${AppConfig.companyLogosPath}/$uid.jpg');
      final task = await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw StorageException(e.toString());
    }
  }
}
