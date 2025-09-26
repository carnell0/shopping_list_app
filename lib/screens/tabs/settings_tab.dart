import 'package:flutter/material.dart';
import '../register_face_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  final String appName = 'Shopping List App';
  final String appVersion = '1.1.0+2';
  final String author = "bycarnell";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.settings_outlined,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.apps,
                  title: 'Nom de l\'application',
                  subtitle: appName,
                ),
                _buildInfoTile(
                  icon: Icons.verified_outlined,
                  title: 'Version',
                  subtitle: appVersion,
                ),
                _buildInfoTile(
                  icon: Icons.group_outlined,
                  title: 'Auteur',
                  subtitle: author,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTappableTile(
                  context: context,
                  icon: Icons.face,
                  title: 'Enregistrer mon visage',
                  subtitle: 'Utiliser la reconnaissance faciale',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterFaceScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTappableTile(
                  context: context,
                  icon: Icons.star_outlined,
                  title: 'Notez nous',
                  subtitle: 'Laissez une note sur le store',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildTappableTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
