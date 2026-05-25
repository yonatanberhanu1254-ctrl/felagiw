/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'CareerConnect';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String employersCollection = 'employers';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String savedJobsCollection = 'saved_jobs';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String notificationsCollection = 'notifications';

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String resumesPath = 'resumes';
  static const String companyLogosPath = 'company_logos';

  // Pagination
  static const int jobsPageSize = 15;
  static const int applicationsPageSize = 20;
  static const int notificationsPageSize = 20;
  static const int chatsPageSize = 30;

  // Job types
  static const List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Remote',
    'Hybrid',
    'Freelance',
  ];

  // Job categories
  static const List<String> jobCategories = [
    'Technology',
    'Design',
    'Marketing',
    'Finance',
    'Healthcare',
    'Education',
    'Engineering',
    'Business',
    'Legal',
    'Sales',
    'Customer Service',
    'Human Resources',
    'Data Science',
    'Research',
    'Media & Communication',
  ];

  // Experience levels
  static const List<String> experienceLevels = [
    'No Experience',
    'Entry Level (0-1 yr)',
    'Junior (1-3 yrs)',
    'Mid-Level (3-5 yrs)',
    'Senior (5+ yrs)',
  ];

  // Application statuses
  static const String statusPending = 'pending';
  static const String statusReviewed = 'reviewed';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';
  static const String statusShortlisted = 'shortlisted';

  // User roles
  static const String roleStudent = 'student';
  static const String roleEmployer = 'employer';
  static const String roleAdmin = 'admin';
}
