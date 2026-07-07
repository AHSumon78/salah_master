import 'package:alarm/screens/commons/appBar_background.dart';
import 'package:alarm/screens/commons/app_background.dart';
import 'package:alarm/screens/helper/app.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ডার্ক মোড কিনা চেক করার জন্য
    final isDarkMode = theme.brightness == Brightness.dark;

    // ডিফল্ট কালার সেটআপ (থিম এক্সটেনশন ছাড়া)
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardBg = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
            Colors.grey;
    final borderColor = isDarkMode ? Colors.white12 : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBarCommon(
        title: "About",
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🖼️ ১. অ্যাপ লোগো / প্রোফাইল পিকচার
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardBg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/icons/iconx.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // অ্যাপের নাম ও ট্যাগলাইন
              Text(
                App.appName(),
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                "Smart Prayer Assistant & Automation",
                style: TextStyle(fontSize: 14, color: subtitleColor),
              ),
              const SizedBox(height: 24),

              // 📝 ২. About App সেকশন কার্ড
              _buildSectionCard(
                cardBg,
                borderColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(textColor, Icons.info_outline, "About App"),
                    const SizedBox(height: 12),
                    Text(
                      "An intelligent location-based alarm and automation system. "
                      "It automatically silences your phone when entering mosque boundaries using geofencing technology "
                      "and provides a reliable weekly smart alarm schedule with advanced preview reminders.",
                      style: TextStyle(
                          fontSize: 14, height: 1.4, color: textColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final versionText = snapshot.hasData
                        ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                        : 'Version';

                    return Text(
                      versionText,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    );
                  },
                ),
              ),
              // const SizedBox(height: 16),

              // // 💻 ৩. Developers সেকশন কার্ড
              // _buildSectionCard(
              //   cardBg,
              //   borderColor,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       _buildHeaderRow(textColor, Icons.code, "Developers"),
              //       const SizedBox(height: 16),

              //       // ডেভেলপার ১: মোহাম্মদ সুমন আলী
              //       _buildDeveloperRow(
              //         context,
              //         textColor,
              //         subtitleColor,
              //         imagePath:
              //             'assets/images/sumon.jpg', // আপনার সঠিক ইমেজ পাথ দিন
              //         name: "Md. Sumon Ali",
              //         dept: "Computer Science and Engineering",
              //         session: "Session: 2021-22",
              //         onPhonePressed: () {}, // url_launcher লজিক এখানে দিন
              //         onFbPressed: () {},
              //       ),

              //       Padding(
              //         padding: const EdgeInsets.symmetric(vertical: 12.0),
              //         child: Divider(
              //             height: 1, thickness: 0.5, color: borderColor),
              //       ),

              //       // ডেভেলপার ২
              //       _buildDeveloperRow(
              //         context,
              //         textColor,
              //         subtitleColor,
              //         imagePath: 'assets/images/partner.jpg',
              //         name: "Co-Developer Name",
              //         dept: "Computer Science and Engineering",
              //         session: "Session: 2021-22",
              //         onPhonePressed: () {},
              //         onFbPressed: () {},
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 16),

              // 📞 ৪. Contact & Support সেকশন কার্ড
              _buildSectionCard(
                cardBg,
                borderColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(
                        textColor, Icons.help_outline, "Contact & Support"),
                    const SizedBox(height: 12),
                    _buildSupportTile(
                        textColor,
                        subtitleColor,
                        Icons.language,
                        "Visit Website",
                        "https://butterflydevs.web.app",
                        () => _launchURL("https://butterflydevs.web.app")),
                    _buildSupportTile(
                        textColor,
                        subtitleColor,
                        Icons.facebook,
                        "Facebook Page",
                        "https://www.facebook.com/butterflydevs/",
                        () => _launchURL(
                            "https://www.facebook.com/butterflydevs/")),
                    _buildSupportTile(
                        textColor,
                        subtitleColor,
                        Icons.email_outlined,
                        "Email",
                        "mmdsumonali@gmail.com",
                        () => _launchURL("mailto:mmdsumonali@gmail.com")),
                    _buildSupportTile(
                        textColor,
                        subtitleColor,
                        Icons.email_outlined,
                        "Privacy Policy",
                        "https://butterflydevs.web.app/projects/salah-master/privacy-policy",
                        () => _launchURL(
                            "https://butterflydevs.web.app/projects/salah-master/privacy-policy")),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 🛡️ ৫. ফুটার কপিরাইট
              Text(
                "Powered by",
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
              const SizedBox(height: 4),
              const Text(
                "ButterfyDevs",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // কন্টেইনার কার্ড বিল্ডার
  Widget _buildSectionCard(Color cardBg, Color borderColor,
      {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  // সেকশন হেডার আইকন ও টেক্সট
  Widget _buildHeaderRow(Color textColor, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }

  // ডেভেলপার প্রোফাইল রোউ
  // Widget _buildDeveloperRow(
  //   BuildContext context,
  //   Color textColor,
  //   Color subtitleColor, {
  //   required String imagePath,
  //   required String name,
  //   required String dept,
  //   required String session,
  //   required VoidCallback onPhonePressed,
  //   required VoidCallback onFbPressed,
  // }) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       CircleAvatar(
  //         radius: 28,
  //         backgroundColor: Colors.grey.withValues(alpha: 0.2),
  //         backgroundImage: AssetImage(imagePath),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               name,
  //               style: TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold,
  //                   color: textColor),
  //             ),
  //             const SizedBox(height: 2),
  //             Text(
  //               dept,
  //               style: TextStyle(fontSize: 13, color: subtitleColor),
  //             ),
  //             Text(
  //               session,
  //               style: TextStyle(
  //                   fontSize: 11, color: subtitleColor.withValues(alpha: 0.8)),
  //             ),
  //             const SizedBox(height: 6),
  //             Row(
  //               children: [
  //                 _buildCircleActionButton(Icons.phone, onPhonePressed),
  //                 const SizedBox(width: 10),
  //                 _buildCircleActionButton(Icons.facebook, onFbPressed),
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ছোট রাউন্ড বাটন (ফোন ও ফেসবুক)
  // Widget _buildCircleActionButton(IconData icon, VoidCallback onPressed) {
  //   return InkWell(
  //     onTap: onPressed,
  //     customBorder: const CircleBorder(),
  //     child: Container(
  //       padding: const EdgeInsets.all(6),
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: Colors.teal.withValues(alpha: 0.1),
  //       ),
  //       child: Icon(icon, size: 16, color: Colors.teal),
  //     ),
  //   );
  // }

  // কন্টাক্ট লিস্ট টাইল
  Widget _buildSupportTile(
    Color textColor,
    Color subtitleColor,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      // 👈 Add this widget here
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 24,
        leading: Icon(icon, color: textColor.withValues(alpha: 0.7), size: 22),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 14, color: textColor.withValues(alpha: 0.3)),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }
}
