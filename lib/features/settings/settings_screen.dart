import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isArabic = settings.language == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'NurApp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                isArabic ? 'التفضيلات' : 'Preferences',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Calculation Method
              _SettingsTile(
                icon: Icons.calculate_rounded,
                title: isArabic ? 'طريقة الحساب' : 'Calculation Method',
                subtitle: settings.calculationMethod,
                trailing: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
                onTap: () => _showMethodPicker(context, ref, isArabic),
              ),
              const SizedBox(height: 10),

              // Madhab
              _SettingsTile(
                icon: Icons.school_rounded,
                title: isArabic ? 'المذهب' : 'Asr Madhab',
                subtitle: settings.madhab,
                trailing: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
                onTap: () => _showMadhabPicker(context, ref, isArabic),
              ),
              const SizedBox(height: 10),

              // Dark Mode
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: isArabic ? 'المظهر' : 'App Theme',
                subtitle: isArabic
                    ? 'تبديل الوضع الداكن'
                    : 'Switch to Dark Mode',
                trailing: Switch(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => notifier.toggleTheme(),
                  activeThumbColor: AppColors.gold,
                ),
                onTap: () => notifier.toggleTheme(),
              ),
              const SizedBox(height: 10),

              // Language
              _SettingsTile(
                icon: Icons.language_rounded,
                title: isArabic ? 'اللغة' : 'Language',
                subtitle: isArabic
                    ? 'اختر لغة العرض'
                    : 'Select display language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LangButton(
                      label: 'EN',
                      selected: settings.language == 'en',
                      onTap: () => notifier.setLanguage('en'),
                    ),
                    const SizedBox(width: 6),
                    _LangButton(
                      label: 'AR',
                      selected: settings.language == 'ar',
                      onTap: () => notifier.setLanguage('ar'),
                    ),
                  ],
                ),
                onTap: null,
              ),
              const SizedBox(height: 24),

              // Premium card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'تجربة السكينة' : 'Experience Serenity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'افتح المزامنة السحابية ومجموعات الأذكار الحصرية.'
                          : 'Unlock cloud synchronization, exclusive adkar collections, and high-resolution prayer widgets.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isArabic
                              ? 'الترقية إلى بريميوم'
                              : 'Upgrade to Premium',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // App info
              Center(
                child: Column(
                  children: [
                    const Text(
                      'نور • NUR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showMethodPicker(BuildContext context, WidgetRef ref, bool isArabic) {
    final methods = [
      'Muslim World League',
      'Egyptian General Authority',
      'University of Islamic Sciences, Karachi',
      'Umm Al-Qura University, Makkah',
      'Islamic Society of North America',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ...methods.map(
            (m) => ListTile(
              title: Text(m),
              onTap: () {
                ref.read(settingsProvider.notifier).setCalculationMethod(m);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showMadhabPicker(BuildContext context, WidgetRef ref, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ...['Hanafi', 'Shafi'].map(
            (m) => ListTile(
              title: Text(m),
              onTap: () {
                ref.read(settingsProvider.notifier).setMadhab(m);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
