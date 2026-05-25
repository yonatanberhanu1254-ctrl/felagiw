import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Firestore job listing model.
class JobModel extends Equatable {
  final String id;
  final String employerId;
  final String companyName;
  final String? companyLogoUrl;
  final bool companyVerified;
  final String title;
  final String description;
  final String? requirements;
  final String? location;
  final String jobType; // full-time, part-time, internship, contract, remote
  final String category;
  final String experienceLevel;
  final double? salaryMin;
  final double? salaryMax;
  final bool remote;
  final List<String> skills;
  final DateTime deadline;
  final String status; // active | closed
  final int applicantCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JobModel({
    required this.id,
    required this.employerId,
    required this.companyName,
    this.companyLogoUrl,
    this.companyVerified = false,
    required this.title,
    required this.description,
    this.requirements,
    this.location,
    required this.jobType,
    required this.category,
    required this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    this.remote = false,
    this.skills = const [],
    required this.deadline,
    this.status = 'active',
    this.applicantCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      employerId: data['employerId'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
      companyVerified: data['companyVerified'] ?? false,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: data['requirements'],
      location: data['location'],
      jobType: data['jobType'] ?? 'full-time',
      category: data['category'] ?? 'Technology',
      experienceLevel: data['experienceLevel'] ?? 'Entry Level (0-1 yr)',
      salaryMin: (data['salaryMin'] as num?)?.toDouble(),
      salaryMax: (data['salaryMax'] as num?)?.toDouble(),
      remote: data['remote'] ?? false,
      skills: List<String>.from(data['skills'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      status: data['status'] ?? 'active',
      applicantCount: data['applicantCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'employerId': employerId,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'companyVerified': companyVerified,
        'title': title,
        'description': description,
        'requirements': requirements,
        'location': location,
        'jobType': jobType,
        'category': category,
        'experienceLevel': experienceLevel,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'remote': remote,
        'skills': skills,
        'deadline': Timestamp.fromDate(deadline),
        'status': status,
        'applicantCount': applicantCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  bool get isExpired => deadline.isBefore(DateTime.now());

  bool get isActive => status == 'active' && !isExpired;

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Negotiable';
    if (salaryMin != null && salaryMax != null) {
      return '\$${salaryMin!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} - \$${salaryMax!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
    }
    final val = salaryMin ?? salaryMax;
    return '\$${val!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  }

  JobModel copyWith({
    String? id,
    String? employerId,
    String? companyName,
    String? companyLogoUrl,
    bool? companyVerified,
    String? title,
    String? description,
    String? requirements,
    String? location,
    String? jobType,
    String? category,
    String? experienceLevel,
    double? salaryMin,
    double? salaryMax,
    bool? remote,
    List<String>? skills,
    DateTime? deadline,
    String? status,
    int? applicantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      JobModel(
        id: id ?? this.id,
        employerId: employerId ?? this.employerId,
        companyName: companyName ?? this.companyName,
        companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
        companyVerified: companyVerified ?? this.companyVerified,
        title: title ?? this.title,
        description: description ?? this.description,
        requirements: requirements ?? this.requirements,
        location: location ?? this.location,
        jobType: jobType ?? this.jobType,
        category: category ?? this.category,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        salaryMin: salaryMin ?? this.salaryMin,
        salaryMax: salaryMax ?? this.salaryMax,
        remote: remote ?? this.remote,
        skills: skills ?? this.skills,
        deadline: deadline ?? this.deadline,
        status: status ?? this.status,
        applicantCount: applicantCount ?? this.applicantCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, title, employerId, status, applicantCount];
}
