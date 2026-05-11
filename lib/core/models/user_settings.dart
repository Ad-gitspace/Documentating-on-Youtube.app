import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String defaultTitle;
  final String defaultDescription;
  final bool autoUploadEnabled;
  final String preferredPrivacy;

  const UserSettings({
    required this.defaultTitle,
    required this.defaultDescription,
    required this.autoUploadEnabled,
    required this.preferredPrivacy,
  });

  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserSettings(
      defaultTitle: data['defaultTitle'] as String? ?? 'DocsMe Upload',
      defaultDescription: data['defaultDescription'] as String? ?? 'Uploaded via DocsMe App',
      autoUploadEnabled: data['autoUploadEnabled'] as bool? ?? false,
      preferredPrivacy: data['preferredPrivacy'] as String? ?? 'private',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultTitle': defaultTitle,
      'defaultDescription': defaultDescription,
      'autoUploadEnabled': autoUploadEnabled,
      'preferredPrivacy': preferredPrivacy,
    };
  }
}
