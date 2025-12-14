class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.handle,
    required this.status,
    required this.bio,
    this.profilePicture,
    required this.lastSeenAt,
    required this.lastSeenLabel,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final String handle;
  final String status;
  final String bio;
  final String? profilePicture;
  final DateTime lastSeenAt;
  final String lastSeenLabel;
  final bool isCurrentUser;
}
