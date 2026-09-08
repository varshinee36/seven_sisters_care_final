import 'package:flutter/material.dart';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  String _selectedTheme = "System";
  String _selectedFontSize = "Medium";

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

  void _showAppLaunchSnackbar(String appName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Launching $appName..."),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF005F46),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : double.infinity,
            margin: screenWidth > 600
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 30 : 0),
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
                              child: Icon(Icons.favorite, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005F46),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up,
                            color: Colors.black87, size: 28),
                        onPressed: () {
                          // TODO: Connect voice-over audio later.
                        },
                        tooltip: 'Voice over',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFCFEDE2)),

                // Settings Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Theme
                        _buildSectionHeader(Icons.palette_outlined, "Theme"),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                title: "Light",
                                subtitle: "Clean white background with dark text",
                                value: "Light",
                                groupValue: _selectedTheme,
                                onChanged: (val) {
                                  setState(() => _selectedTheme = val!);
                                },
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildRadioTile(
                                title: "Dark",
                                subtitle: "Low-light dark contrast mode",
                                value: "Dark",
                                groupValue: _selectedTheme,
                                onChanged: (val) {
                                  setState(() => _selectedTheme = val!);
                                },
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildRadioTile(
                                title: "System",
                                subtitle: "Follow device system preferences",
                                value: "System",
                                groupValue: _selectedTheme,
                                onChanged: (val) {
                                  setState(() => _selectedTheme = val!);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section 2: Font Size
                        _buildSectionHeader(
                            Icons.format_size_rounded, "Font Size"),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                title: "Small",
                                subtitle: "Standard compact text sizing",
                                value: "Small",
                                groupValue: _selectedFontSize,
                                onChanged: (val) {
                                  setState(() => _selectedFontSize = val!);
                                },
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildRadioTile(
                                title: "Medium (Default)",
                                subtitle: "Balanced readability and comfort",
                                value: "Medium",
                                groupValue: _selectedFontSize,
                                onChanged: (val) {
                                  setState(() => _selectedFontSize = val!);
                                },
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _buildRadioTile(
                                title: "Large",
                                subtitle: "High visibility large text for easy reading",
                                value: "Large",
                                groupValue: _selectedFontSize,
                                onChanged: (val) {
                                  setState(() => _selectedFontSize = val!);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section 3: Quick Access Apps
                        _buildSectionHeader(
                            Icons.apps_rounded, "Quick Access Apps"),
                        const SizedBox(height: 10),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _quickAccessApps.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final app = _quickAccessApps[index];
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              elevation: 1,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () =>
                                    _showAppLaunchSnackbar(app["name"]),
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
                                              app["name"],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              app["desc"],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new_rounded,
                                        color: Color(0xFF005F46),
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
                          const Text(
                            "Back",
                            style: TextStyle(
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF005F46), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF005F46),
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
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFF005F46),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
