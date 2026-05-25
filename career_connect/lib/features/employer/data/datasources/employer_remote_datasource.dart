import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';

abstract class EmployerRemoteDataSource {
  Future<EmployerModel> getEmployerProfile(String uid);
  Future<void> updateEmployerProfile(EmployerModel employer);
  Future<String> uploadCompanyLogo({required String uid, required String filePath});
}

class EmployerRemoteDataSourceImpl implements EmployerRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EmployerRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Future<EmployerModel> getEmployerProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.employersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) throw const ServerException('Employer profile not found');
      return EmployerModel.fromFirestore(doc);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateEmployerProfile(EmployerModel employer) async {
    try {
      await _firestore
          .collection(AppConfig.employersCollection)
          .doc(employer.uid)
          .update(employer.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadCompanyLogo({
    required String uid,
    required String filePath,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('${AppConfig.companyLogosPath}/$uid/logo.jpg');
      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
