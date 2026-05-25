import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Firestore user document model.
class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' | 'employer' | 'admin'
  final String? photoUrl;
  final String? university;
  final String? department;
  final String? phone;
  final List<String> skills;
  final String? resumeUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final String? bio;
  final String? location;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.university,
    this.department,
    this.phone,
    this.skills = const [],
    this.resumeUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioUrl,
    this.bio,
    this.location,
    this.emailVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      photoUrl: data['photoUrl'],
      university: data['university'],
      department: data['department'],
      phone: data['phone'],
      skills: List<String>.from(data['skills'] ?? []),
      resumeUrl: data['resumeUrl'],
      githubUrl: data['githubUrl'],
      linkedinUrl: data['linkedinUrl'],
      portfolioUrl: data['portfolioUrl'],
      bio: data['bio'],
      location: data['location'],
      emailVerified: data['emailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'university': university,
        'department': department,
        'phone': phone,
        'skills': skills,
        'resumeUrl': resumeUrl,
        'githubUrl': githubUrl,
        'linkedinUrl': linkedinUrl,
        'portfolioUrl': portfolioUrl,
        'bio': bio,
        'location': location,
        'emailVerified': emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    String? university,
    String? department,
    String? phone,
    List<String>? skills,
    String? resumeUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    String? bio,
    String? location,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        photoUrl: photoUrl ?? this.photoUrl,
        university: university ?? this.university,
        department: department ?? this.department,
        phone: phone ?? this.phone,
        skills: skills ?? this.skills,
        resumeUrl: resumeUrl ?? this.resumeUrl,
        githubUrl: githubUrl ?? this.githubUrl,
        linkedinUrl: linkedinUrl ?? this.linkedinUrl,
        portfolioUrl: portfolioUrl ?? this.portfolioUrl,
        bio: bio ?? this.bio,
        location: location ?? this.location,
        emailVerified: emailVerified ?? this.emailVerified,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Completion percentage for student profile.
  double get completionPercentage {
    int filled = 0;
    const total = 9;
    if (name.isNotEmpty) filled++;
    if (email.isNotEmpty) filled++;
    if (university != null && university!.isNotEmpty) filled++;
    if (department != null && department!.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    if (photoUrl != null) filled++;
    if (resumeUrl != null) filled++;
    if (githubUrl != null || linkedinUrl != null) filled++;
    if (bio != null && bio!.isNotEmpty) filled++;
    return filled / total;
  }

  @override
  List<Object?> get props => [uid, name, email, role, photoUrl, skills, resumeUrl, emailVerified];
}
