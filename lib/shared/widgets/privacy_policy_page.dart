import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1F477D);
    const accentColor = Color(0xFFF0B84D);
    const backgroundColor = Color(0xFFFAFAFA);
    const textDark = Color(0xFF1A1A1A);
    const textLight = Color(0xFF666666);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 900
                ? 60
                : MediaQuery.of(context).size.width > 600
                    ? 32
                    : 20,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 40 : 32,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Last updated: December 4, 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Effective Date: January 1, 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Introduction
              _buildIntroductionSection(),
              const SizedBox(height: 40),

              // Sections
              _buildSection(
                '1. Information We Collect',
                [
                  'Personal Information: Name, email address, phone number, and profile data',
                  'Business Information: Business name, location, registration details, and operating hours',
                  'Usage Data: Device information, IP address, app usage patterns, and browsing history',
                  'Location Data: Geographic location (only with your explicit permission)',
                  'Communication Records: Messages, support tickets, and feedback',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '2. How We Use Your Information',
                [
                  'Provide and improve our services and user experience',
                  'Authenticate and verify user identity and account security',
                  'Process transactions and manage offers',
                  'Send notifications, updates, and support communications',
                  'Analyze usage patterns to optimize our platform',
                  'Comply with legal obligations and regulations',
                  'Personalize your experience and content recommendations',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '3. Information Sharing',
                [
                  'We do NOT sell your personal information to third parties',
                  'Shop Owners: Your information is shared when you interact with their offers',
                  'Service Providers: Trusted partners assisting in platform operations',
                  'Legal Compliance: When required by law or to protect legal rights',
                  'With Your Consent: Only when you explicitly agree to share data',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '4. Data Security',
                [
                  'Industry-Standard Encryption: All data transmitted using SSL/TLS protocols',
                  'Firebase Security: Secured authentication and database with strict rules',
                  'Restricted Access: Limited to authorized personnel only',
                  'Regular Updates: Continuous security patches and improvements',
                  'No Method is 100% Secure: While we work hard to protect your data, no method is entirely secure',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '5. Your Rights & Choices',
                [
                  'Access Your Data: View all personal information we hold about you',
                  'Update Your Information: Modify your profile and preferences anytime',
                  'Delete Your Account: Request complete data deletion',
                  'Opt-Out: Control marketing communications and notifications',
                  'Data Portability: Request a copy of your data in portable format',
                  'Location Control: Manage location services in app settings',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '6. Data Retention',
                [
                  'Account Data: Retained while your account is active',
                  'Usage Data: Kept for 12 months for analytics purposes',
                  'Communication Records: Stored for 24 months for support purposes',
                  'Deleted Data: Permanently removed from our systems within 30 days',
                  'Legal Requirements: Data may be retained if required by law',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '7. Third-Party Services',
                [
                  'Firebase: Google\'s cloud services for authentication and data storage',
                  'Payment Processors: Secure third-party payment gateways',
                  'Analytics Tools: Google Analytics for usage insights',
                  'Email Services: Third-party email delivery services',
                  'These services have their own privacy policies that you should review',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '8. Children\'s Privacy',
                [
                  'Our services are not directed to children under 13 years old',
                  'We do not knowingly collect personal information from children',
                  'If we discover such information, we will delete it immediately',
                  'Parents/guardians may contact us to review or delete child data',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '9. International Data Transfers',
                [
                  'Your data may be transferred to and stored in different countries',
                  'We ensure that international transfers comply with applicable laws',
                  'Data protection standards may vary by country',
                  'By using our services, you consent to such transfers',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '10. Policy Updates',
                [
                  'We may update this policy to reflect changes in our practices',
                  'Major changes will be communicated to you via email',
                  'Continued use of our services constitutes acceptance of changes',
                  'Review this policy periodically for updates',
                ],
              ),
              const SizedBox(height: 48),

              // Important Notice
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(10),
                  border:
                      Border.all(color: const Color(0xFF1F477D).withAlpha(30)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outlined,
                            color: primaryColor, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'If you have questions, concerns, or wish to exercise your privacy rights, please email us at privacy@offora.com. We are committed to protecting your privacy and maintaining transparency about our practices.',
                      style: TextStyle(
                        fontSize: 14,
                        color: textLight,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, Color(0xFF2A5A9F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outlined, color: accentColor, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Your Privacy Matters to Us',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We are committed to protecting your personal information and maintaining the highest standards of data security. Your trust is our priority.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(230),
                        height: 1.6,
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

  Widget _buildIntroductionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B84D),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Our Commitment to Privacy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'At Offora, protecting your privacy is our highest priority. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and website.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: points.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0B84D).withAlpha(26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFFF0B84D),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
