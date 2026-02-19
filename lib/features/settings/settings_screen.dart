import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme.dart';
import '../../data/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final box = Hive.box('app_settings');
    final username = box.get('username', defaultValue: 'Kullanıcı') as String;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: isDark
                ? AppTheme.backgroundBlack
                : AppTheme.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Ayarlar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Profile Card ──
                  _buildProfileCard(context, username),
                  const SizedBox(height: 24),

                  // ── Appearance Section ──
                  _buildSectionTitle(context, 'Görünüm'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context,
                    children: [
                      _buildThemeToggle(context, isDark, themeNotifier),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── General Section ──
                  _buildSectionTitle(context, 'Genel'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.notifications_outlined,
                        iconColor: AppTheme.accentOrange,
                        title: 'Bildirimler',
                        subtitle: 'Hatırlatıcı ayarları',
                        onTap: () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsTile(
                        context,
                        icon: Icons.language_outlined,
                        iconColor: AppTheme.accentBlue,
                        title: 'Dil',
                        subtitle: 'Türkçe',
                        onTap: () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsTile(
                        context,
                        icon: Icons.backup_outlined,
                        iconColor: AppTheme.accentTeal,
                        title: 'Veri Yedekleme',
                        subtitle: 'Verilerini yedekle',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── About Section ──
                  _buildSectionTitle(context, 'Hakkında'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        iconColor: AppTheme.accentPurple,
                        title: 'Uygulama Sürümü',
                        subtitle: 'Auro v3.0.0',
                        showArrow: false,
                        onTap: () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsTile(
                        context,
                        icon: Icons.description_outlined,
                        iconColor: Colors.grey,
                        title: 'Gizlilik Politikası',
                        subtitle: 'Verileriniz güvende',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Logout Button ──
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Çıkış Yap'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String username) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.accentPurple.withValues(alpha: 0.25),
                  AppTheme.accentTeal.withValues(alpha: 0.15),
                ]
              : [
                  AppTheme.accentPurple.withValues(alpha: 0.12),
                  AppTheme.accentTeal.withValues(alpha: 0.08),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.accentTeal, AppTheme.accentPurple],
              ),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Auro Premium Üye ✨',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted(context)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.accentTeal,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    bool isDark,
    ThemeModeNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.withValues(alpha: 0.15)
                  : Colors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.amber : Colors.indigo,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                Text(
                  isDark ? 'Koyu Tema' : 'Açık Tema',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: !isDark,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              notifier.toggle();
            },
            activeColor: AppTheme.accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary(context),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 12,
              ),
            )
          : null,
      trailing: showArrow
          ? Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted(context),
            )
          : null,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      color: AppTheme.dividerColor(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Çıkış Yap',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Çıkış yapmak istediğine emin misin?',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: TextStyle(color: AppTheme.textMuted(context)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final box = await Hive.openBox('app_settings');
              await box.put('isLoggedIn', false);
              await box.put('username', '');
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (context.mounted) {
                GoRouter.of(context).go('/login');
              }
            },
            child: const Text(
              'Çıkış',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
