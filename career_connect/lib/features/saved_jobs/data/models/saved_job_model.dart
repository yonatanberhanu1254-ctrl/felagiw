import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Saved job bookmark model.
class SavedJobModel extends Equatable {
  final String id;
  final String studentId;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogoUrl;
  final String jobType;
  final String? location;
  final bool remote;
  final double? salaryMin;
  final double? salaryMax;
  final DateTime savedAt;
  final DateTime jobDeadline;

  const SavedJobModel({
    required this.id,
    required this.studentId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoUrl,
    required this.jobType,
    this.location,
    this.remote = false,
    this.salaryMin,
    this.salaryMax,
    required this.savedAt,
    required this.jobDeadline,
  });

  factory SavedJobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedJobModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
      jobType: data['jobType'] ?? 'full-time',
      location: data['location'],
      remote: data['remote'] ?? false,
      salaryMin: (data['salaryMin'] as num?)?.toDouble(),
      salaryMax: (data['salaryMax'] as num?)?.toDouble(),
      savedAt: (data['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jobDeadline: (data['jobDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'studentId': studentId,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'jobType': jobType,
        'location': location,
        'remote': remote,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'savedAt': FieldValue.serverTimestamp(),
        'jobDeadline': Timestamp.fromDate(jobDeadline),
      };

  bool get isExpired => jobDeadline.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, studentId, jobId];
}
