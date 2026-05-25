import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/saved_jobs/data/models/saved_job_model.dart';

abstract class SavedJobsRemoteDataSource {
  Future<List<SavedJobModel>> getSavedJobs(String studentId);
  Future<void> saveJob(SavedJobModel savedJob);
  Future<void> unsaveJob({required String studentId, required String jobId});
  Future<bool> isJobSaved({required String studentId, required String jobId});
}

class SavedJobsRemoteDataSourceImpl implements SavedJobsRemoteDataSource {
  final FirebaseFirestore _firestore;
  SavedJobsRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(AppConfig.savedJobsCollection);

  @override
  Future<List<SavedJobModel>> getSavedJobs(String studentId) async {
    try {
      final snap = await _ref
          .where('studentId', isEqualTo: studentId)
          .orderBy('savedAt', descending: true)
          .get();
      return snap.docs.map((d) => SavedJobModel.fromFirestore(d)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> saveJob(SavedJobModel savedJob) async {
    try {
      await _ref.add(savedJob.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unsaveJob({required String studentId, required String jobId}) async {
    try {
      final snap = await _ref
          .where('studentId', isEqualTo: studentId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isJobSaved({required String studentId, required String jobId}) async {
    try {
      final snap = await _ref
          .where('studentId', isEqualTo: studentId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
