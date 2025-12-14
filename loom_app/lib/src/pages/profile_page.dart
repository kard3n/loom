import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/images_controller.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/pages/full_screen_image_page.dart';
import 'package:loom_app/src/pages/full_screen_post_page.dart';
import 'package:loom_app/src/widgets/path_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isSaving = false;

  String? _profilePicturePath;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _enterEditMode({
    required String name,
    required String status,
    required String bio,
    required String? profilePicture,
  }) {
    _nameController.text = name;
    _statusController.text = status;
    _bioController.text = bio;
    _profilePicturePath = profilePicture;
    setState(() => _isEditing = true);
  }

  Future<void> _saveEdits(ProfilesController profilesController) async {
    final String name = _nameController.text.trim();
    final String status = _statusController.text.trim();
    final String bio = _bioController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await profilesController.updateCurrentUser(
        name: name,
        status: status,
        bio: bio,
        profilePicture: _profilePicturePath,
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      Get.snackbar('Error', 'Failed to save profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final profilesController = Get.find<ProfilesController>();
    final postsController = Get.find<PostsController>();
    final imagesController = Get.find<ImagesController>();

    return Obx(() {
      final profile = profilesController.currentUser();
      final displayName = profile?.name ?? 'You';
      final bio = profile?.bio ?? '';
      final status = profile?.status ?? '';
      final String? currentProfilePicture = profile?.profilePicture;
      final recent = postsController.posts
          .where((Post p) => p.authorId == (profile?.id ?? ''))
          .take(2)
          .toList(growable: false);

        final pinned = postsController.pinnedPosts(includeClips: false);

      return Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: cs.surface,
              foregroundColor: cs.onSurface,
              title: Text(displayName),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        cs.primaryContainer,
                        cs.surface,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              final String? picture = _isEditing
                                  ? _profilePicturePath
                                  : currentProfilePicture;

                              if (_isEditing) {
                                final String? saved =
                                    await imagesController.pickAndStoreImage(
                                  folder: 'profile_pictures',
                                );
                                if (!mounted) return;
                                if (saved == null) return;
                                setState(() => _profilePicturePath = saved);
                                return;
                              }

                              if (picture == null || picture.trim().isEmpty) {
                                return;
                              }

                              FullScreenImagePage.open(context, picture);
                            },
                            child: ClipOval(
                              child: Container(
                                width: 80,
                                height: 80,
                                color: cs.primary.withValues(alpha: 0.15),
                                alignment: Alignment.center,
                                child: () {
                                  final String? picture =
                                      _isEditing ? _profilePicturePath : currentProfilePicture;
                                  if (picture != null && picture.trim().isNotEmpty) {
                                    return PathImage(
                                      path: picture,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return Text(
                                    _initial(displayName),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                                  );
                                }(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (_isEditing)
                                  TextField(
                                    controller: _nameController,
                                    maxLines: 1,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Name',
                                    ),
                                  )
                                else
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                if (_isEditing)
                                  TextField(
                                    controller: _statusController,
                                    maxLines: 1,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Status',
                                    ),
                                  )
                                else
                                  Text(
                                    status,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _StatsRow(
                      items: <_StatItem>[
                        const _StatItem(label: 'Totems', value: '—'),
                        const _StatItem(label: 'Posts', value: '—'),
                        const _StatItem(label: 'Friends', value: '—'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.message_rounded),
                            label: const Text('Message'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () async {
                                    if (!_isEditing) {
                                      _enterEditMode(
                                        name: displayName,
                                        status: status,
                                        bio: bio,
                                        profilePicture: currentProfilePicture,
                                      );
                                    } else {
                                      await _saveEdits(profilesController);
                                    }
                                  },
                            icon: Icon(
                              _isEditing
                                  ? Icons.check_rounded
                                  : Icons.person_add_alt_1_rounded,
                            ),
                            label: Text(_isEditing ? 'Save' : 'Edit'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'About',
                      child: _isEditing
                          ? TextField(
                              controller: _bioController,
                              maxLines: 4,
                              minLines: 2,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Bio',
                              ),
                              style: theme.textTheme.bodyMedium,
                            )
                          : Text(
                              bio.isNotEmpty
                                  ? bio
                                  : 'This user has not added a bio yet.',
                              style: theme.textTheme.bodyMedium,
                            ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Pinned',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (pinned.isEmpty)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.bookmarks_outlined),
                              title: const Text('No pinned items'),
                              subtitle: const Text('Pins will show up here when available.'),
                            )
                          else
                            ...pinned
                                .map(
                                  (Post post) => _PostPlaceholderTile(
                                    title: (post.title.isNotEmpty && post.title != 'Untitled')
                                        ? post.title
                                        : post.text,
                                    subtitle: '${post.timeAgoLabel} • ${post.text}'.trim(),
                                    onTap: () => FullScreenPostPage.open(context, post.id),
                                  ),
                                )
                                .expand(
                                  (w) => <Widget>[w, const Divider(height: 1)],
                                )
                                .toList(growable: false)
                                .take((pinned.length * 2) - 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Recent posts',
                      child: Column(
                        children: <Widget>[
                          if (recent.isEmpty)
                            const _PostPlaceholderTile(
                              title: 'No posts yet',
                              subtitle: 'Posts will show up here when available.',
                            )
                          else ...<Widget>[
                            _PostPlaceholderTile(
                              title: (recent.first.title.isNotEmpty && recent.first.title != 'Untitled')
                                  ? recent.first.title
                                  : recent.first.text,
                              subtitle: '${recent.first.timeAgoLabel} • ${recent.first.text}'.trim(),
                              onTap: () => FullScreenPostPage.open(context, recent.first.id),
                            ),
                            if (recent.length > 1) ...<Widget>[
                              const Divider(height: 1),
                              _PostPlaceholderTile(
                                title: (recent[1].title.isNotEmpty && recent[1].title != 'Untitled')
                                    ? recent[1].title
                                    : recent[1].text,
                                subtitle: '${recent[1].timeAgoLabel} • ${recent[1].text}'.trim(),
                                onTap: () => FullScreenPostPage.open(context, recent[1].id),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PostPlaceholderTile extends StatelessWidget {
  const _PostPlaceholderTile({required this.title, required this.subtitle, this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.chat_bubble_outline_rounded),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: items
              .map(
                (_StatItem item) => Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.value,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;
}

String _initial(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}