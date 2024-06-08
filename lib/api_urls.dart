class ApiUrls {
  static const String ipAddress = '192.168.176.226';
  static const String baseUrl = 'http://$ipAddress:3000/api';
  static const String patientRegistration = '$baseUrl/patient';
  static const String loginUrl = '$baseUrl/patient/loginPatient';
  static const String userDetailsUrl = '$baseUrl/patient/details';
  static const String doctorsUrl = '$baseUrl/doctors';
  static const String quizUrl = '$baseUrl/quizzes';
  static String testsUrl(int? patientId) => '$baseUrl/tests/${patientId ?? ''}';
  static String devicesUrl(int patientId) => '$baseUrl/devices/$patientId ';
  static const String doctorsNameUrl = '$baseUrl/doctorsName';
  static const String medicalFolderUrlPrefix = '$baseUrl/medicalfolder/';
  static const String patientsDoctorUrlPrefix = '$baseUrl/patients/';
  static const String optionalDoctorUrl = '$baseUrl/optionalDoctor';
  static const String passwordRecoveryUrl = '$baseUrl/patient/recoverpsswrd';
  static const String passwordResetUrl = '$baseUrl/patient/resetpassword';
  static String patientProfileUrl(int patientId) => '$baseUrl/patient/profile/$patientId';
  static String medicalFolderUrl(int patientId) => '$baseUrl/medicalfolder/patient/$patientId';
  static const String verifyCodeUrl = '$baseUrl/patient/verify';
  static String updateProfileUrl(int patientId) => '$baseUrl/patient/$patientId/updateProfile';
  static String updateMedicalFolderUrl(int patientId) => '$baseUrl/medicalfolder/$patientId/updateMedicalFolder';
  static const String createDkaHistoryUrl = '$baseUrl/createDkaHistory';
  static String dkaHistoryUrl(int? medicalFolderId) => '$baseUrl/dkaHistory/${medicalFolderId ?? ''}';
  static String deleteDkaHistoryUrl(int dkaHistoryId) => '$baseUrl/deleteDH/$dkaHistoryId';
  static String modifyPasswordUrl(int patientId) => '$baseUrl/patients/$patientId/password';
  static const String RecSys = '$baseUrl/recommendations';
  static String fcmTokenUrl(int patientId) => '$baseUrl/patients/$patientId/fcmtoken';
  static const String latestLocationUrl = '$baseUrl/LatestLocation';
  static const String sendLocationUrl = '$baseUrl/location';
  static const String deleteDKA = '$baseUrl/deleteDH';
  static const String userManualPDF = '$baseUrl/user_manual.pdf';
  static const String addRecommendation = '$baseUrl/addrecommendation';
  static const String dailyNotif = '$baseUrl/dailyNotif';

}