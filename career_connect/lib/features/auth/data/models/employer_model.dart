import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Firestore employer/company document model.
class EmployerModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String companyName;
  final String? industry;
  final String? website;
  final String? logoUrl;
  final String? description;
  final String? location;
  final String? phone;
  final bool verified;
  final int totalJobsPosted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EmployerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.companyName,
    this.industry,
    this.website,
    this.logoUrl,
    this.description,
    this.location,
    this.phone,
    this.verified = false,
    this.totalJobsPosted = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory EmployerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployerModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      companyName: data['companyName'] ?? '',
      industry: data['industry'],
      website: data['website'],
      logoUrl: data['logoUrl'],
      description: data['description'],
      location: data['location'],
      phone: data['phone'],
      verified: data['verified'] ?? false,
      totalJobsPosted: data['totalJobsPosted'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': 'employer',
        'companyName': companyName,
        'industry': industry,
        'website': website,
        'logoUrl': logoUrl,
        'description': description,
        'location': location,
        'phone': phone,
        'verified': verified,
        'totalJobsPosted': totalJobsPosted,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  EmployerModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? companyName,
    String? industry,
    String? website,
    String? logoUrl,
    String? description,
    String? location,
    String? phone,
    bool? verified,
    int? totalJobsPosted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      EmployerModel(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        companyName: companyName ?? this.companyName,
        industry: industry ?? this.industry,
        website: website ?? this.website,
        logoUrl: logoUrl ?? this.logoUrl,
        description: description ?? this.description,
        location: location ?? this.location,
        phone: phone ?? this.phone,
        verified: verified ?? this.verified,
        totalJobsPosted: totalJobsPosted ?? this.totalJobsPosted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [uid, email, companyName, verified];
}
