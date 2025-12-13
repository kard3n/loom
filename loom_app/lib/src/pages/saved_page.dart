import 'package:flutter/material.dart';

// 1. Define the new screen/window
class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key, required this.item});

  final _SavedItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: item.accent.withOpacity(0.5),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Template content for the new window
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'By ${item.author}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              const Text(
                'Full Excerpt:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // The text content you requested
              Text(
                item.excerpt,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the current screen
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData sectionTheme = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB300),
        brightness: base.brightness,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBF2),
    );

    return Theme(
      data: sectionTheme,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
        itemCount: _items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Saved',
                    style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Library of threads, posts, and rituals you pinned for later.',
                    style: sectionTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          final _SavedItem item = _items[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Container(
                decoration: BoxDecoration(
                  color: item.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.title,
                                  style: sectionTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'by ${item.author}',
                                  style: sectionTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // The existing More button
                          // The existing More button
                          IconButton(
                            onPressed: () {
                              // FIX APPLIED HERE: Wrapped the content in SafeArea
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea( // <-- This widget ensures system navigation bars don't overlap content
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min, // Allows the sheet to take minimum vertical space
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.share),
                                          title: const Text('Share Item'),
                                          onTap: () => Navigator.pop(context),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                                          title: const Text('Unsave', style: TextStyle(color: Colors.red)),
                                          onTap: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.more_horiz_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.excerpt,
                        style: sectionTheme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Chip(
                            avatar: const Icon(Icons.bookmark_added_rounded, size: 16),
                            label: Text(item.tag),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          // 2. The New Button to open a new window
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              // Use Navigator to push the new screen/window onto the stack
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => ItemDetailsPage(item: item),
                                ),
                              );
                            },
                            child: const Text('View'),
                          ),
                          // The original text moved to the end
                          Text(
                            item.savedAgo,
                            style: sectionTheme.textTheme.bodySmall?.copyWith(color: sectionTheme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SavedItem {
  const _SavedItem({
    required this.title,
    required this.author,
    required this.excerpt,
    required this.tag,
    required this.savedAgo,
    required this.accent,
  });

  final String title;
  final String author;
  final String excerpt;
  final String tag;
  final String savedAgo;
  final Color accent;
}