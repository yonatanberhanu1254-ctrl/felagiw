import 'package:flutter/material.dart';
import 'package:career_connect/core/theme/app_colors.dart';

/// Maps application status strings to colors and labels.
class StatusHelper {
  StatusHelper._();

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'reviewed':
        return AppColors.statusReviewed;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'rejected':
        return AppColors.statusRejected;
      case 'shortlisted':
        return AppColors.statusShortlisted;
      default:
        return AppColors.statusPending;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'shortlisted':
        return 'Shortlisted';
      default:
        return 'Unknown';
    }
  }

  static Color getJobTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full-time':
        return AppColors.fullTime;
      case 'part-time':
        return AppColors.partTime;
      case 'internship':
        return AppColors.internship;
      case 'remote':
        return AppColors.remote;
      case 'contract':
        return AppColors.contract;
      default:
        return AppColors.primary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'reviewed':
        return Icons.visibility_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'shortlisted':
        return Icons.star_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
