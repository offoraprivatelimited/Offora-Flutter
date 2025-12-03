import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms and Conditions',
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
          _buildSection(
            '1. Acceptance of Terms',
            'By accessing or using the Offora platform ("Platform"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the Platform.',
          ),
          _buildSection(
            '2. Definitions',
            '• "Platform" refers to the Offora mobile and web application\n• "User" refers to any individual browsing and using offers\n• "Shop Owner" refers to businesses creating and managing offers\n• "Offer" refers to promotional deals posted by Shop Owners\n• "We", "Us", "Our" refers to Offora',
          ),
          _buildSection(
            '3. User Accounts',
            '3.1. You must be at least 18 years old to create an account.\n\n3.2. You are responsible for maintaining the confidentiality of your account credentials.\n\n3.3. You agree to provide accurate, current, and complete information during registration.\n\n3.4. You are responsible for all activities that occur under your account.',
          ),
          _buildSection(
            '4. Shop Owner Responsibilities',
            '4.1. Shop Owners must provide accurate business information and valid documentation.\n\n4.2. All offers must comply with applicable laws and regulations.\n\n4.3. Shop Owners are responsible for honoring all offers posted on the Platform.\n\n4.4. Shop Owners must not post misleading, fraudulent, or deceptive offers.\n\n4.5. Offora reserves the right to approve, reject, or remove any offer at our discretion.',
          ),
          _buildSection(
            '5. User Conduct',
            '5.1. Users must not misuse the Platform or use it for illegal purposes.\n\n5.2. Users must not attempt to manipulate, hack, or disrupt the Platform.\n\n5.3. Users must respect the intellectual property rights of others.\n\n5.4. Harassment, abusive behavior, or spam is strictly prohibited.',
          ),
          _buildSection(
            '6. Offers and Transactions',
            '6.1. All offers are subject to availability and may change without notice.\n\n6.2. Offora acts as a platform connecting Users and Shop Owners but is not a party to any transaction.\n\n6.3. Users should verify offer details directly with Shop Owners before making purchases.\n\n6.4. Offora is not responsible for disputes between Users and Shop Owners.',
          ),
          _buildSection(
            '7. Intellectual Property',
            '7.1. All content on the Platform, including logos, designs, and text, is owned by Offora or its licensors.\n\n7.2. Users may not copy, reproduce, or distribute Platform content without permission.\n\n7.3. Shop Owners grant Offora a license to display their offers and business information on the Platform.',
          ),
          _buildSection(
            '8. Disclaimer of Warranties',
            '8.1. The Platform is provided "as is" without warranties of any kind.\n\n8.2. We do not guarantee the accuracy, reliability, or availability of the Platform.\n\n8.3. We do not guarantee that offers will be honored by Shop Owners.\n\n8.4. Use of the Platform is at your own risk.',
          ),
          _buildSection(
            '9. Limitation of Liability',
            '9.1. Offora shall not be liable for any indirect, incidental, or consequential damages.\n\n9.2. Our total liability shall not exceed the amount paid by you to Offora in the last 12 months.\n\n9.3. We are not responsible for third-party content, offers, or services.',
          ),
          _buildSection(
            '10. Privacy',
            'Your use of the Platform is subject to our Privacy Policy, which is incorporated into these Terms by reference.',
          ),
          _buildSection(
            '11. Termination',
            '11.1. We reserve the right to suspend or terminate your account at any time for violation of these Terms.\n\n11.2. You may delete your account at any time through the app settings.\n\n11.3. Upon termination, your right to use the Platform ceases immediately.',
          ),
          _buildSection(
            '12. Changes to Terms',
            'We reserve the right to modify these Terms at any time. Continued use of the Platform after changes constitutes acceptance of the modified Terms.',
          ),
          _buildSection(
            '13. Governing Law',
            'These Terms shall be governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in Chennai, Tamil Nadu.',
          ),
          _buildSection(
            '14. Contact Information',
            'For questions about these Terms, please contact us at:\n\nEmail: legal@offora.com\nPhone: +91 98765 43210\nAddress: 123, Business District, Chennai, Tamil Nadu, India - 600001',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0B84D).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF0B84D).withAlpha(77),
              ),
            ),
            child: const Text(
              'By using Offora, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
              textAlign: TextAlign.center,
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
