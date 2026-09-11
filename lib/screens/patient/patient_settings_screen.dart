import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_launcher_service.dart';
import '../../services/app_settings_service.dart';
import '../../providers/language_provider.dart';
import '../../services/language_service.dart';
import '../../localization/app_localizations.dart';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  final List<Map<String, dynamic>> _quickAccessApps = [
    {
      "name": "YouTube",
      "icon": Icons.play_circle_fill,
      "color": const Color(0xFFFF0000),
      "desc": "Video & Music Therapy",
    },
    {
      "name": "WhatsApp",
      "icon": Icons.chat_bubble,
      "color": const Color(0xFF25D366),
      "desc": "Family Messages",
    },
    {
      "name": "Instagram",
      "icon": Icons.camera_alt,
      "color": const Color(0xFFE1306C),
      "desc": "Photo Sharing",
    },
    {
      "name": "Google Contacts",
      "icon": Icons.contacts,
      "color": const Color(0xFF4285F4),
      "desc": "Care Network",
    },
    {
      "name": "Phone Dialer",
      "icon": Icons.phone,
      "color": const Color(0xFF005F46),
      "desc": "Direct Call",
    },
  ];

  Future<void> _handleAppLaunch(String appName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Opening $appName..."),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF005F46),
      ),
    );

    bool launched = false;
    switch (appName) {
      case "YouTube":
        launched = await AppLauncherService.launchYouTube();
        break;
      case "WhatsApp":
        launched = await AppLauncherService.launchWhatsApp();
        break;
      case "Instagram":
        launched = await AppLauncherService.launchInstagram();
        break;
      case "Google Contacts":
        launched = await AppLauncherService.launchContacts();
        break;
      case "Phone Dialer":
        launched = await AppLauncherService.launchPhoneDialer();
        break;
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Opening $appName in browser or device fallback."),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF005F46),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final settings = AppSettingsService.instance;
    LanguageProvider? languageProvider;
    try {
      languageProvider = Provider.of<LanguageProvider>(context, listen: true);
    } catch (_) {
      languageProvider = null;
    }
    final currentLangCode = languageProvider?.languageCode ??
        LanguageService.instance.getSavedLanguage();
    final loc = context.loc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF242E2A) : Colors.white;
    final containerBg =
        isDark ? const Color(0xFF1B2320) : const Color(0xFFF7FAF8);
    final textMain = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141917) : const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : double.infinity,
            margin: screenWidth > 600
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius:
                  BorderRadius.circular(screenWidth > 600 ? 30 : 0),
            ),
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 16, bottom: 8),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const CircleAvatar(
                              radius: 25,
                              backgroundColor: Color(0xFF005F46),
                              child: Icon(Icons.favorite,
                                  color: Colors.white),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.settings,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF74B49B)
                                : const Color(0xFF005F46),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up,
                            color: isDark ? Colors.white70 : Colors.black87,
                            size: 28),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${loc.voiceOver}: ${loc.settings}"),
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF005F46),
                            ),
                          );
                        },
                        tooltip: loc.voiceOver,
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2C3934)
                      : const Color(0xFFCFEDE2),
                ),

                // Settings Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Language (Offline Localization)
                        _buildSectionHeader(
                            Icons.language_rounded, loc.language, isDark),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildRadioTile(
                                title: loc.english,
                                subtitle: "English language interface",
                                value: "en",
                                groupValue: currentLangCode,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    if (languageProvider != null) {
                                      languageProvider.setLanguage(val);
                                    } else {
                                      LanguageService.instance.saveLanguage(val);
                                    }
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.hindi,
                                subtitle: "हिंदी भाषा इंटरफ़ेस",
                                value: "hi",
                                groupValue: currentLangCode,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    if (languageProvider != null) {
                                      languageProvider.setLanguage(val);
                                    } else {
                                      LanguageService.instance.saveLanguage(val);
                                    }
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.assamese,
                                subtitle: "অসমীয়া ভাষা ইণ্টাৰফেচ",
                                value: "as",
                                groupValue: currentLangCode,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    if (languageProvider != null) {
                                      languageProvider.setLanguage(val);
                                    } else {
                                      LanguageService.instance.saveLanguage(val);
                                    }
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.bengali,
                                subtitle: "বাংলা ভাষা ইন্টারফেস",
                                value: "bn",
                                groupValue: currentLangCode,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    if (languageProvider != null) {
                                      languageProvider.setLanguage(val);
                                    } else {
                                      LanguageService.instance.saveLanguage(val);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section 2: Theme
                        _buildSectionHeader(
                            Icons.palette_outlined, loc.theme, isDark),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildRadioTile(
                                title: loc.light,
                                subtitle: loc.lightDesc,
                                value: "Light",
                                groupValue: settings.themeName,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      settings.setTheme(val);
                                    });
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.dark,
                                subtitle: loc.darkDesc,
                                value: "Dark",
                                groupValue: settings.themeName,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      settings.setTheme(val);
                                    });
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.system,
                                subtitle: loc.systemDesc,
                                value: "System",
                                groupValue: settings.themeName,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      settings.setTheme(val);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section 3: Font Size
                        _buildSectionHeader(Icons.format_size_rounded,
                            loc.fontSize, isDark),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildRadioTile(
                                title: loc.small,
                                subtitle: loc.smallDesc,
                                value: "Small",
                                groupValue: settings.fontSizeName,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      settings.setFontSize(val);
                                    });
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.medium,
                                subtitle: loc.mediumDesc,
                                value: "Medium",
                                groupValue: settings.fontSizeName,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      settings.setFontSize(val);
                                    });
                                  }
                                },
                              ),
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: isDark
                                    ? const Color(0xFF2C3934)
                                    : Colors.grey.shade200,
                              ),
                              _buildRadioTile(
                                title: loc.large,
                                subtitle: loc.largeDesc,
                                value: "Large",
                                groupValue: settings.fontSizeName,
                                textColor: textMain,
                                subtitleColor: textMuted,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      settings.setFontSize(val);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section 4: Quick Access Apps
                        _buildSectionHeader(Icons.apps_rounded,
                            loc.quickAccessApps, isDark),
                        const SizedBox(height: 10),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _quickAccessApps.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final app = _quickAccessApps[index];
                            return Material(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              elevation: 1,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _handleAppLaunch(
                                    app["name"] as String),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: (app["color"] as Color)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          app["icon"] as IconData,
                                          color: app["color"] as Color,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              app["name"] as String,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: textMain,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              app["desc"] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.open_in_new_rounded,
                                        color: isDark
                                            ? const Color(0xFF74B49B)
                                            : const Color(0xFF005F46),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Back Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF19D3F3),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            loc.back,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, bool isDark) {
    final color =
        isDark ? const Color(0xFF74B49B) : const Color(0xFF005F46);
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required Color textColor,
    required Color subtitleColor,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? const Color(0xFF005F46)
                  : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
