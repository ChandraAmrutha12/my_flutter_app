import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      routes: {
        '/': (_) => HomeScreen(toggleTheme: toggleTheme),
        '/settings': (_) => SettingsScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
      },
    );
  }

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebSocketChannel channel;
  Map<String, dynamic> serverData = {"a": 0, "b": 0, "c": 0};

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.20.207:8000/ws'));
    channel.stream.listen((data) {
      final parsedData = jsonDecode(data);
      setState(() => serverData = parsedData);
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _showProfilePopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Profile Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(leading: Icon(Icons.person), title: Text("Username"), subtitle: Text("johndoe123")),
            ListTile(leading: Icon(Icons.lock), title: Text("Password"), subtitle: Text("••••••••")),
            ListTile(leading: Icon(Icons.email), title: Text("john@example.com")),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Search Clicked")))),
          IconButton(icon: const Icon(Icons.person), onPressed: _showProfilePopup),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildValueTile("Value A", serverData['a']),
            _buildValueTile("Value B", serverData['b']),
            _buildValueTile("Value C", serverData['c']),
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text("$label: $value", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  const SettingsScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text("Profile"), trailing: const Icon(Icons.edit), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))),
          const Divider(),
          ListTile(title: const Text("Change Password"), onTap: () {}),
          ListTile(title: const Text("Update Email"), onTap: () => _showEditEmailDialog(context)),
          ListTile(title: const Text("Manage Connected Accounts"), onTap: () => _showAddAccount(context)),
          ListTile(title: const Text("Delete Account"), onTap: () => _showDeleteAccounts(context)),
          SwitchListTile(title: const Text("Dark Mode"), value: isDarkMode, onChanged: (_) => toggleTheme()),
          ListTile(title: const Text("Privacy Policy"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicyPage(title: "Privacy Policy")))),
          ListTile(title: const Text("Terms & Conditions"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicyPage(title: "Terms & Conditions")))),
          ListTile(title: const Text("Select Language"), onTap: () => _showLanguageDialog(context)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(mainAxisSize: MainAxisSize.min, children: ["English", "Telugu", "Hindi"].map((lang) => ListTile(title: Text(lang), onTap: () => Navigator.pop(context))).toList()),
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(text: "user@example.com");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Email"),
        content: TextField(controller: controller, decoration: const InputDecoration(suffixIcon: Icon(Icons.edit))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Save"))],
      ),
    );
  }

  void _showAddAccount(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Account"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Account Email')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Add"))],
      ),
    );
  }

  void _showDeleteAccounts(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Delete account functionality goes here."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
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
            TextFormField(initialValue: "John Doe", decoration: const InputDecoration(labelText: "Name")),
            TextFormField(initialValue: "user@example.com", decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Save Changes")),
          ],
        ),
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
        child: Text(title == "Privacy Policy" ? "This is the privacy policy content." : "These are the terms and conditions."),
      ),
    );
  }
}
