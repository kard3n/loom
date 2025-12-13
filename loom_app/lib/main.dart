import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/app_values_controller.dart';
import 'package:loom_app/src/controllers/main_controller.dart';
import 'package:loom_app/src/pages/friends_page.dart';
import 'package:loom_app/src/pages/feed_page.dart';
import 'package:loom_app/src/pages/Settings/Settings_page.dart';
import 'package:loom_app/src/pages/saved_page.dart';
import 'package:loom_app/src/pages/totems_page.dart';
import 'package:loom_app/src/bindings/app_bindings.dart';
import 'package:loom_app/src/rust/frb_generated.dart';
import 'package:flutter/services.dart';

// ------------------- MAIN -------------------
import 'package:loom_app/src/rust/api/simple.dart';

Future<void> main() async {
  // Ensure that Flutter is bound before RustLib is initialized
  WidgetsFlutterBinding.ensureInitialized();
  //String result = await greet(name: "Test name");
  await RustLib.init();

  Get.put(AppValuesController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends GetView<AppValuesController> {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: controller.appTitle.value,
        debugShowCheckedModeBanner: false,
        initialBinding: AppBindings(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: controller.seedColor.value),
          scaffoldBackgroundColor: controller.appScaffoldBackground.value,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends GetView<MainController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeScreenBody(controller: controller);
  }
}

// creates a window when Compose is clicked
class Compose extends StatelessWidget {
  const Compose({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme for consistent styling
    final theme = Theme.of(context);
    final values = Get.find<AppValuesController>();

    return Scaffold(
      // 1. Elegant App Bar: No shadow and a clear close button
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // Scaffold background color
        elevation: 0, // Removes the shadow under the AppBar
        title: Text(
          'Create New Post', // Translated text
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Logic to close the screen
            Navigator.of(context).pop(); 
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // *ACTION: Logic to publish the post*
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post published successfully!')),
                );
              },
              // 2. Styled "Post" button
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Post', // Translated text
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 3. Title/Subject input field
            const TextField(
              decoration: InputDecoration(
                hintText: 'Title (optional)', // Translated text
                border: InputBorder.none, // No border
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(height: 30),
            
            // 4. Main text area
            const TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null, // Allows unlimited lines
              decoration: InputDecoration(
                hintText: 'What would you like to post?', // Translated text
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 30),
            
            // 5. Additional actions (images, tags, etc.)
            Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  tooltip: 'Add Image', // Translated text
                  onPressed: () {
                    // *ACTION: Image picker logic*
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open image picker...')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.tag),
                  tooltip: 'Add Tags', // Translated text
                  onPressed: () {
                    // *ACTION: Tag management logic*
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open tag editor...')),
                    );
                  },
                ),
                const Spacer(), // Pushes the following element to the right
                // Optional: Character counter or status indicator
                Text(
                  '0/280',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

// creates a window when new totem is clicked
class NewTotem extends StatelessWidget {
  const NewTotem({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = Get.find<AppValuesController>();

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Totem', // Translated text
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // *ACTION: Logic to save/create the Totem*
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Totem created successfully!')),
              );
            },
            child: const Text(
              'Save', // Translated text
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Visual representation / Image upload
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    // *ACTION: Logic to upload an image*
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open image picker for Totem...')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 2. Name / Title of the Totem
            Text(
              'Name', // Translated text
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Give your Totem a name...', // Translated text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Description
            Text(
              'Description', // Translated text
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the meaning of your Totem...', // Translated text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            
            // 4. Category/Type selection (Example for a dropdown)
            Text(
              'Totem Type', // Translated text
              style: theme.textTheme.titleMedium,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              hint: const Text('Select a type'), // Translated text
              items: <String>['Achievement', 'Memory', 'Goal'] // Translated items
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
              onChanged: (String? newValue) {
                // *ACTION: Save value*
              },
            ),
          ],
        ),
      ),
    ));
  }
}

// creates a window when invite friends is clicked
class InviteFriends extends StatelessWidget {
  const InviteFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const inviteLink = "https://your-app.com/invite/XYZ123";

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends'), // Translated text
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Large prompt
            Text(
              'Share the Fun!', // Translated text
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Invite your friends to unlock rewards or create content together.', // Translated text
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),

            // 2. Invitation link area
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        values.inviteLink.value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: 'Copy Link', // Translated text
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        // *ACTION: Copy logic*
                        Clipboard.setData(const ClipboardData(text: inviteLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied!')), // Translated text
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 3. Buttons for different shares
            Text(
              'Or share via:', // Translated text
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 15),

            // Example: Row with Share buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareButton(context, Icons.email_outlined, 'Email', () {
                  // *ACTION: Share via Email logic*
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing via Email...')),
                  );
                }),
                _buildShareButton(context, Icons.sms_outlined, 'SMS', () {
                  // *ACTION: Share via SMS logic*
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing via SMS...')),
                  );
                }),
                _buildShareButton(context, Icons.share_outlined, 'Other', () {
                  // *ACTION: Logic for native share (e.g., using share_plus package)*
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Showing native share options...')),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  // Helper widget for the Share buttons
  Widget _buildShareButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody({required this.controller});

  final MainController controller;

  void _openComposeWindow() {
    Get.to(() => const Compose());
  }

  void _openNewTotemWindow() {
    Get.to(() => const NewTotem());
  }

  void _openInviteFriendsWindow() {
    Get.to(() => const InviteFriends());
  }

  @override
  void initState() {
    super.initState();
    _items = <_NavigationItem>[
      _NavigationItem(
        label: 'Home',
        icon: Icons.home_rounded,
        page: const FeedPage(),
        fabLabel: 'Compose',
        fabIcon: Icons.edit_rounded,
        onFabTap: () => _openComposeWindow(),
      ),
      _NavigationItem(
        label: 'Totems',
        icon: Icons.auto_awesome_rounded,
        page: const TotemsPage(),
        fabLabel: 'New totem',
        fabIcon: Icons.auto_fix_high_rounded,
        onFabTap: () => _openNewTotemWindow(),
      ),
      _NavigationItem(
        label: 'Friends',
        icon: Icons.groups_2_rounded,
        page: const FriendsPage(),
        fabLabel: 'Invite',
        fabIcon: Icons.person_add_alt_1_rounded,
        onFabTap: () => _openInviteFriendsWindow(),
      ),
      _NavigationItem(
        label: 'Saved',
        icon: Icons.bookmark_added_rounded,
        page: const SavedPage(),
      ),
      _NavigationItem(
        label: 'Settings',
        icon: Icons.settings_rounded,
        page: const SettingsPage(),
      ),
    ];
  }

  // The _showAction method remains (already in English)
  void _showAction(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final _NavigationItem activeItem = _items[_selectedIndex];
    return Scaffold(
      floatingActionButton: activeItem.fabIcon != null
          ? FloatingActionButton.extended(
              onPressed: activeItem.onFabTap,
              icon: Icon(activeItem.fabIcon),
              label: Text(activeItem.fabLabel!),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: _items
            .map(
              (_NavigationItem item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _items.map((_NavigationItem item) => item.page).toList(),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.page,
    this.fabLabel,
    this.fabIcon,
    this.onFabTap,
  });

  final String label;
  final IconData icon;
  final Widget page;
  final String? fabLabel;
  final IconData? fabIcon;
  final VoidCallback? onFabTap;
}
