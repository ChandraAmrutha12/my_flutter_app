import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function toggleTheme;

  const SettingsScreen({super.key, required this.toggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  List<String> connectedAccounts = ['user1@example.com', 'user2@example.com'];
  String email = 'user@example.com';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("English"), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text("Telugu"), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text("Hindi"), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showEditEmailDialog() {
    TextEditingController controller = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Email"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(suffixIcon: Icon(Icons.edit)),
        ),
        actions: [
          TextButton(
              onPressed: () {
                setState(() => email = controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save"))
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicyPage(title: "Privacy Policy")));
  }

  void _showTerms() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicyPage(title: "Terms & Conditions")));
  }

  void _showAddAccount() {
    TextEditingController accountController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Account"),
        content: TextField(
          controller: accountController,
          decoration: const InputDecoration(labelText: 'Account Email'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => connectedAccounts.add(accountController.text));
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _showDeleteAccounts() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: connectedAccounts.map((account) {
            return ListTile(
              title: Text(account),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() => connectedAccounts.remove(account));
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Profile"),
            trailing: const Icon(Icons.edit),
            onTap: _editProfile,
          ),
          const Divider(),
          ListTile(title: const Text("Change Password"), onTap: () {}),
          ListTile(title: const Text("Update Email"), onTap: _showEditEmailDialog),
          ListTile(title: const Text("Manage Connected Accounts"), onTap: _showAddAccount),
          ListTile(title: const Text("Delete Account"), onTap: _showDeleteAccounts),
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: isNotificationsEnabled,
            onChanged: (val) => setState(() => isNotificationsEnabled = val),
          ),
          SwitchListTile(
            title: const Text("App Lock"),
            value: false,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('dark_mode', val);
              setState(() => isDarkMode = val);
              widget.toggleTheme();
            },
          ),
          ListTile(title: const Text("Privacy Policy"), onTap: _showPrivacyPolicy),
          ListTile(title: const Text("Terms & Conditions"), onTap: _showTerms),
          ListTile(title: const Text("Select Language"), onTap: _changeLanguage),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class PolicyPage extends StatelessWidget {
  final String title;
  const PolicyPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title == "Privacy Policy"
              ? "This is the privacy policy content."
              : "These are the terms and conditions.",
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: "John Doe",
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextFormField(
              initialValue: "user@example.com",
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}
