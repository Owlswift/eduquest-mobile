import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/push/push_registration_service.dart';
import '../../../../core/storage/settings_storage.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../users/services/users_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _settingsStorage = SettingsStorage();
  bool _pushEnabled = true;
  bool _loadingToggle = false;

  // Kept in sync with pubspec.yaml's `version:` by hand - avoids pulling in
  // a plugin (package_info_plus) just to read it at runtime.
  static const _version = '1.0.0 (1)';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _settingsStorage.getPushEnabled();
    if (mounted) setState(() => _pushEnabled = enabled);
  }

  Future<void> _togglePush(bool value) async {
    setState(() => _loadingToggle = true);
    await _settingsStorage.setPushEnabled(value);
    if (value) {
      await PushRegistrationService().registerThisDevice();
    } else {
      await PushRegistrationService().unregisterThisDevice();
    }
    if (mounted) {
      setState(() {
        _pushEnabled = value;
        _loadingToggle = false;
      });
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Current password'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const Gap(12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'New password'),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                if (error != null) ...[
                  const Gap(10),
                  Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                try {
                  await UsersService().changePassword(currentController.text, newController.text);
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } on Exception catch (e) {
                  final msg = e.toString().contains('401') || e.toString().contains('incorrect')
                      ? 'Current password is incorrect'
                      : "Couldn't change password - try again.";
                  setDialogState(() => error = msg);
                }
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This permanently deletes your account and all progress - coins, XP, '
          'badges, certificates, everything. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await UsersService().deleteAccount();
      if (mounted) {
        await ref.read(authControllerProvider.notifier).logout();
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't delete your account - try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: _changePassword,
              ),
            ],
          ),
          const Gap(20),
          _SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Push Notifications',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Get notified about badges, rewards, and competitions',
                    style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12)),
                value: _pushEnabled,
                onChanged: _loadingToggle ? null : _togglePush,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const Gap(20),
          _SettingsSection(
            title: 'Danger Zone',
            children: [
              _SettingsTile(
                icon: Icons.delete_forever_rounded,
                label: 'Delete Account',
                labelColor: AppColors.danger,
                onTap: _deleteAccount,
              ),
            ],
          ),
          const Gap(24),
          Center(
            child: Text(
              'EduQuest v$_version',
              style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.subtitle,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.card,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      leading: Icon(icon, color: labelColor ?? AppColors.subtitle),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: labelColor ?? AppColors.text,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subtitle),
    );
  }
}
