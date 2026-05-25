import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Firestore application document model.
class ApplicationModel extends Equatable {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogoUrl;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentPhotoUrl;
  final String employerId;
  final String status; // pending, reviewed, shortlisted, accepted, rejected
  final String? coverLetter;
  final String? resumeUrl;
  final DateTime appliedAt;
  final DateTime? updatedAt;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoUrl,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentPhotoUrl,
    required this.employerId,
    this.status = 'pending',
    this.coverLetter,
    this.resumeUrl,
    required this.appliedAt,
    this.updatedAt,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      studentPhotoUrl: data['studentPhotoUrl'],
      employerId: data['employerId'] ?? '',
      status: data['status'] ?? 'pending',
      coverLetter: data['coverLetter'],
      resumeUrl: data['resumeUrl'],
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'studentPhotoUrl': studentPhotoUrl,
        'employerId': employerId,
        'status': status,
        'coverLetter': coverLetter,
        'resumeUrl': resumeUrl,
        'appliedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? companyLogoUrl,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? studentPhotoUrl,
    String? employerId,
    String? status,
    String? coverLetter,
    String? resumeUrl,
    DateTime? appliedAt,
    DateTime? updatedAt,
  }) =>
      ApplicationModel(
        id: id ?? this.id,
        jobId: jobId ?? this.jobId,
        jobTitle: jobTitle ?? this.jobTitle,
        companyName: companyName ?? this.companyName,
        companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
        studentId: studentId ?? this.studentId,
        studentName: studentName ?? this.studentName,
        studentEmail: studentEmail ?? this.studentEmail,
        studentPhotoUrl: studentPhotoUrl ?? this.studentPhotoUrl,
        employerId: employerId ?? this.employerId,
        status: status ?? this.status,
        coverLetter: coverLetter ?? this.coverLetter,
        resumeUrl: resumeUrl ?? this.resumeUrl,
        appliedAt: appliedAt ?? this.appliedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, jobId, studentId, status];
}
