import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';

abstract class ApplicationsRemoteDataSource {
  Future<ApplicationModel> applyForJob(ApplicationModel application);
  Future<List<ApplicationModel>> getStudentApplications(String studentId);
  Future<List<ApplicationModel>> getJobApplicants(String jobId);
  Future<void> updateApplicationStatus({required String applicationId, required String status});
  Future<bool> hasApplied({required String jobId, required String studentId});
  Future<ApplicationModel> getApplicationById(String applicationId);
  Stream<List<ApplicationModel>> watchStudentApplications(String studentId);
}

class ApplicationsRemoteDataSourceImpl implements ApplicationsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ApplicationsRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(AppConfig.applicationsCollection);

  @override
  Future<ApplicationModel> applyForJob(ApplicationModel application) async {
    try {
      final docRef = await _ref.add(application.toFirestore());
      final doc = await docRef.get();
      return ApplicationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApplicationModel>> getStudentApplications(String studentId) async {
    try {
      final snapshot = await _ref
          .where('studentId', isEqualTo: studentId)
          .orderBy('appliedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => ApplicationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApplicationModel>> getJobApplicants(String jobId) async {
    try {
      final snapshot = await _ref
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => ApplicationModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _ref.doc(applicationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> hasApplied({required String jobId, required String studentId}) async {
    try {
      final snapshot = await _ref
          .where('jobId', isEqualTo: jobId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ApplicationModel> getApplicationById(String applicationId) async {
    try {
      final doc = await _ref.doc(applicationId).get();
      if (!doc.exists) throw const NotFoundException('Application not found.');
      return ApplicationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ApplicationModel>> watchStudentApplications(String studentId) {
    return _ref
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ApplicationModel.fromFirestore(doc)).toList());
  }
}
