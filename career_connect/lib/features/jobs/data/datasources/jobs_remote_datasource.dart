import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/domain/repositories/jobs_repository.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobModel>> getJobs({JobFilters? filters, Object? lastDocument, int limit = 15});
  Future<JobModel> getJobById(String jobId);
  Future<List<JobModel>> getRecommendedJobs({required List<String> skills, required String userId, int limit = 10});
  Future<List<JobModel>> getRecentJobs({int limit = 8});
  Future<List<JobModel>> getEmployerJobs(String employerId);
  Future<JobModel> createJob(JobModel job);
  Future<void> updateJob(JobModel job);
  Future<void> deleteJob(String jobId);
  Future<void> incrementApplicantCount(String jobId);
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  final FirebaseFirestore _firestore;

  JobsRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _jobsRef =>
      _firestore.collection(AppConfig.jobsCollection);

  @override
  Future<List<JobModel>> getJobs({
    JobFilters? filters,
    Object? lastDocument,
    int limit = 15,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _jobsRef
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);

      if (filters != null) {
        if (filters.category != null) {
          query = query.where('category', isEqualTo: filters.category);
        }
        if (filters.jobType != null) {
          query = query.where('jobType', isEqualTo: filters.jobType);
        }
        if (filters.experienceLevel != null) {
          query = query.where('experienceLevel', isEqualTo: filters.experienceLevel);
        }
        if (filters.remote == true) {
          query = query.where('remote', isEqualTo: true);
        }
        if (filters.minSalary != null) {
          query = query.where('salaryMin', isGreaterThanOrEqualTo: filters.minSalary);
        }
      }

      if (lastDocument != null && lastDocument is DocumentSnapshot) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);
      final snapshot = await query.get();
      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();

      // Client-side text search if query provided
      if (filters?.query != null && filters!.query!.isNotEmpty) {
        final q = filters.query!.toLowerCase();
        return jobs.where((j) =>
          j.title.toLowerCase().contains(q) ||
          j.companyName.toLowerCase().contains(q) ||
          j.description.toLowerCase().contains(q) ||
          j.skills.any((s) => s.toLowerCase().contains(q))
        ).toList();
      }

      return jobs;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    try {
      final doc = await _jobsRef.doc(jobId).get();
      if (!doc.exists) throw const NotFoundException('Job not found.');
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobModel>> getRecommendedJobs({
    required List<String> skills,
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get jobs matching any of the student's skills
      final snapshot = await _jobsRef
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final jobs = snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();

      if (skills.isEmpty) return jobs.take(limit).toList();

      // Score jobs by skill overlap
      final scored = jobs.map((job) {
        final overlap = job.skills.where((s) =>
          skills.map((sk) => sk.toLowerCase()).contains(s.toLowerCase())
        ).length;
        return MapEntry(job, overlap);
      }).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return scored.take(limit).map((e) => e.key).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobModel>> getRecentJobs({int limit = 8}) async {
    try {
      final snapshot = await _jobsRef
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobModel>> getEmployerJobs(String employerId) async {
    try {
      final snapshot = await _jobsRef
          .where('employerId', isEqualTo: employerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> createJob(JobModel job) async {
    try {
      final docRef = await _jobsRef.add(job.toFirestore());
      final doc = await docRef.get();
      return JobModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateJob(JobModel job) async {
    try {
      final data = job.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _jobsRef.doc(job.id).update(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await _jobsRef.doc(jobId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> incrementApplicantCount(String jobId) async {
    try {
      await _jobsRef.doc(jobId).update({
        'applicantCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
