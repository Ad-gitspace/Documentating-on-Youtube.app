import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/user_settings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/constants/app_dimens.dart';
import '../widgets/glass_card.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _autoUploadEnabled = false;
  String _preferredPrivacy = 'private';
  bool _isLoading = false;

  void _loadSettings(UserSettings settings) {
    _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
    _titleController.text = settings.defaultTitle;
    _descController.text = settings.defaultDescription;
    _autoUploadEnabled = settings.autoUploadEnabled;
    _preferredPrivacy = settings.preferredPrivacy;
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != FirebaseAuth.instance.currentUser?.displayName) {
        await FirebaseService().updateDisplayName(newName);
      }

      final newSettings = UserSettings(
        defaultTitle: _titleController.text.trim(),
        defaultDescription: _descController.text.trim(),
        autoUploadEnabled: _autoUploadEnabled,
        preferredPrivacy: _preferredPrivacy,
      );
      await FirebaseService().saveUserSettings(newSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved'),
            backgroundColor: AppColors.secondary, // Sage green
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings', style: AppTypography.headlineLg.copyWith(color: AppColors.primary)),
      ),
      body: FutureBuilder<UserSettings?>(
        future: FirebaseService().fetchUserSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (snapshot.hasData && _titleController.text.isEmpty && _descController.text.isEmpty) {
            _loadSettings(snapshot.data!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display Name', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Text('Default Video Title', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Text('Default Description', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Auto-Upload Enabled', style: AppTypography.bodyLg.copyWith(color: Colors.white)),
                          Switch(
                            value: _autoUploadEnabled,
                            onChanged: (val) => setState(() => _autoUploadEnabled = val),
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Text('Preferred Privacy', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _preferredPrivacy,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'public', child: Text('Public')),
                          DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')),
                          DropdownMenuItem(value: 'private', child: Text('Private')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _preferredPrivacy = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : Text('Save Settings', style: AppTypography.buttonText.copyWith(color: Colors.black)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
