import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Last Updated: December 4, 2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brightGold.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brightGold.withAlpha(77)),
            ),
            child: const Text(
              'At Offora, we are committed to protecting your privacy and personal information. This Privacy Policy explains how we collect, use, and safeguard your data.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            '1. Information We Collect',
            '1.1. Personal Information:\n• Name, email address, and phone number\n• Profile information and preferences\n• Authentication credentials\n\n1.2. Business Information (Shop Owners):\n• Business name and registration details\n• Contact information\n• Business location and category\n• Tax identification numbers (if provided)\n\n1.3. Usage Information:\n• Device information and IP address\n• App usage patterns and preferences\n• Location data (with your permission)\n• Saved offers and browsing history',
          ),
          _buildSection(
            '2. How We Use Your Information',
            '2.1. To provide and improve our services\n\n2.2. To authenticate and verify your identity\n\n2.3. To process and manage offers\n\n2.4. To communicate with you about offers, updates, and support\n\n2.5. To personalize your experience\n\n2.6. To analyze and improve our Platform\n\n2.7. To comply with legal obligations',
          ),
          _buildSection(
            '3. Information Sharing',
            'We do not sell your personal information. We may share your information only in the following circumstances:\n\n3.1. With Shop Owners when you interact with their offers\n\n3.2. With service providers who assist in operating our Platform (e.g., hosting, analytics)\n\n3.3. When required by law or to protect our legal rights\n\n3.4. With your explicit consent\n\n3.5. In connection with a business transfer or merger',
          ),
          _buildSection(
            '4. Data Security',
            '4.1. We implement industry-standard security measures to protect your data.\n\n4.2. All data transmission is encrypted using SSL/TLS protocols.\n\n4.3. We use Firebase Authentication and Firestore with security rules.\n\n4.4. Access to personal information is restricted to authorized personnel only.\n\n4.5. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
          ),
          _buildSection(
            '5. Your Rights and Choices',
            '5.1. Access: You can access your personal information through your account settings.\n\n5.2. Update: You can update your information at any time.\n\n5.3. Delete: You can request deletion of your account and associated data.\n\n5.4. Opt-out: You can opt-out of marketing communications.\n\n5.5. Data Portability: You can request a copy of your data.\n\n5.6. Location: You can disable location services in your device settings.',
          ),
          _buildSection(
            '6. Cookies and Tracking',
            '6.1. We use cookies and similar technologies to improve your experience.\n\n6.2. These help us remember your preferences and analyze usage patterns.\n\n6.3. You can control cookie settings through your browser.\n\n6.4. We use Google Analytics to understand how users interact with our Platform.',
          ),
          _buildSection(
            '7. Third-Party Services',
            '7.1. Our Platform integrates with third-party services:\n• Firebase (Google) for authentication and database\n• Google Maps for location services\n• Payment processors (if applicable)\n\n7.2. These services have their own privacy policies, which we encourage you to review.\n\n7.3. We are not responsible for third-party privacy practices.',
          ),
          _buildSection(
            '8. Children\'s Privacy',
            'Our Platform is not intended for users under 18 years of age. We do not knowingly collect personal information from children. If we discover that we have collected information from a child, we will delete it promptly.',
          ),
          _buildSection(
            '9. Data Retention',
            '9.1. We retain your personal information for as long as necessary to provide our services.\n\n9.2. Account information is retained until you request deletion.\n\n9.3. Some information may be retained longer for legal or business purposes.\n\n9.4. Deleted data may remain in backups for up to 90 days.',
          ),
          _buildSection(
            '10. International Data Transfers',
            'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.',
          ),
          _buildSection(
            '11. Changes to This Policy',
            'We may update this Privacy Policy from time to time. We will notify you of significant changes through the Platform or via email. Your continued use of the Platform after changes constitutes acceptance of the updated policy.',
          ),
          _buildSection(
            '12. Contact Us',
            'If you have questions or concerns about this Privacy Policy or our data practices, please contact us:\n\nEmail: privacy@offora.com\nPhone: +91 98765 43210\nAddress: 123, Business District, Chennai, Tamil Nadu, India - 600001',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkBlue.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: darkBlue.withAlpha(51)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: darkBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'We are committed to protecting your privacy and being transparent about how we use your data. If you have any concerns, please don\'t hesitate to reach out to us.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F477D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
