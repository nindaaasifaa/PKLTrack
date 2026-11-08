import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.role,
    required this.avatar,
    required this.onEditName,
    super.key,
  });

  final ValueListenable<String> name;
  final String role;
  final Widget avatar;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.primaryContainer, AppTheme.surface],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.outline),
      boxShadow: [
        BoxShadow(
          color: AppTheme.accent.withAlpha(20),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            avatar,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: name,
                    builder: (context, value, _) => Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 20,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Kelola informasi dan foto profil Anda',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: onEditName,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Ubah nama'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accent,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppTheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
      ),
    ],
  );
}

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.outline),
    ),
    child: Column(children: children),
  );
}

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 19, color: AppTheme.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout_outlined),
      label: const Text('Keluar dari akun'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        backgroundColor: Colors.red.withAlpha(10),
        side: BorderSide(color: Colors.red.shade100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
