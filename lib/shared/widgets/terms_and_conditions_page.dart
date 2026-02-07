// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

const primaryColor = Color(0xFF1F477D);
const accentGold = Color(0xFFF0B84D);
const mediumGold = Color(0xFFE6A844);
const lightGold = Color(0xFFFFF8E7);
const primaryDark = Color(0xFF1F477D);

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 600 ? 40 : 32,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Last updated: December 4, 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Effective Date: 07/02/2026',
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
                '1. Acceptance of Terms',
                [
                  'By accessing and using the Offora mobile application and website, you agree to be bound by these Terms and Conditions',
                  'If you do not agree to any part of these terms, you must discontinue use of our services immediately',
                  'We reserve the right to update or modify these terms at any time without prior notice',
                  'Your continued use of the service following such modifications constitutes acceptance of the updated terms',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '2. User Eligibility',
                [
                  'You must be at least 13 years old to use Offora',
                  'By creating an account, you represent that you are legally capable of entering into binding agreements',
                  'You are responsible for maintaining the accuracy of your account information',
                  'You agree not to create multiple accounts or impersonate other users',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '3. User Accounts and Security',
                [
                  'You are responsible for maintaining the confidentiality of your login credentials',
                  'You agree to notify us immediately of any unauthorized use of your account',
                  'You are liable for all activities that occur under your account',
                  'We are not responsible for any unauthorized access to your account due to your negligence',
                  'You must not share your password with third parties',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '4. Use Restrictions',
                [
                  'You agree not to use Offora for illegal, unethical, or unauthorized purposes',
                  'Prohibited activities include: harassment, fraud, hacking, spamming, or spreading malware',
                  'You may not reproduce, distribute, or transmit content without our written permission',
                  'You agree not to attempt to gain unauthorized access to our systems or data',
                  'Violation of these restrictions may result in account suspension or legal action',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '5. User Content and Submissions',
                [
                  'Any content you upload remains your intellectual property',
                  'By uploading content, you grant Offora a non-exclusive license to use, reproduce, and distribute it',
                  'You represent that you have the right to grant such licenses',
                  'We reserve the right to remove content that violates these terms',
                  'You agree not to upload content that is offensive, defamatory, or infringes on intellectual property rights',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '6. Offers and Transactions',
                [
                  'All offers displayed on Offora are subject to availability and may be withdrawn at any time',
                  'Offora is not responsible for the accuracy of offer information provided by shop owners',
                  'Disputes regarding offers should be addressed directly with the relevant shop owner',
                  'Offora acts as a platform facilitator and is not party to transactions between users and shops',
                  'We reserve the right to remove any offers that violate our policies',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '7. Payments and Refunds',
                [
                  'All payments are processed through secure third-party payment gateways',
                  'Offora is not responsible for payment processing failures or delays',
                  'Refund policies are determined by individual shop owners, not by Offora',
                  'Disputes regarding transactions should be reported to our support team',
                  'We will attempt to resolve disputes in a fair and timely manner',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '8. Intellectual Property Rights',
                [
                  'All content on Offora, including logos, text, and graphics, is owned or licensed by us',
                  'You may not reproduce, distribute, or modify this content without permission',
                  'Use of Offora grants you a limited license to view and use content for personal purposes only',
                  'You agree not to use our trademarks, logos, or brand names without authorization',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '9. Disclaimers and Limitations of Liability',
                [
                  'Offora is provided "as is" without any warranties or guarantees',
                  'We do not warrant that our services will be uninterrupted or error-free',
                  'To the maximum extent permitted by law, we disclaim all implied warranties',
                  'Offora shall not be liable for indirect, incidental, or consequential damages',
                  'Our total liability is limited to the amount paid by you for our services',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '10. Termination of Service',
                [
                  'We reserve the right to terminate or suspend your account at our discretion',
                  'Termination may occur if you violate these terms or engage in prohibited activities',
                  'Upon termination, your right to use Offora will immediately cease',
                  'We may delete your account data after a reasonable period',
                  'Termination does not relieve you of any obligations incurred prior to termination',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '11. Third-Party Links and Services',
                [
                  'Offora may contain links to third-party websites and services',
                  'We are not responsible for the content or accuracy of third-party sites',
                  'Your use of third-party services is subject to their terms and conditions',
                  'We do not endorse or guarantee third-party products or services',
                  'You access third-party sites at your own risk',
                ],
              ),
              const SizedBox(height: 32),

              _buildSection(
                '12. Governing Law and Dispute Resolution',
                [
                  'These terms are governed by the laws of India',
                  'Any disputes arising from these terms shall be subject to the exclusive jurisdiction of courts in India',
                  'You agree to attempt amicable resolution before initiating legal proceedings',
                  'In case of disputes, you may contact our support team at support@offora.com',
                ],
              ),
              const SizedBox(height: 48),

              // Important Notice
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(10),
                  border: Border.all(color: Color(0xFF1F477D).withAlpha(30)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.gavel_outlined,
                            color: primaryColor, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Important Notice',
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
                      'These terms constitute the entire agreement between you and Offora regarding your use of our services. If you have any questions about these terms, please contact us at support@offora.com.',
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [primaryColor, Color(0xFF2A5A9F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.verified_outlined,
                            color: accentColor, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Binding Agreement',
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
                      'By using Offora, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions. Thank you for being part of our platform.',
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
                  'Welcome to Offora',
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
          Text(
            'These Terms and Conditions govern your use of the Offora mobile application and website. Please read them carefully before using our platform. By accessing and using Offora, you accept and agree to be bound by all the terms and conditions outlined herein.',
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF666666),
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
                    child: Center(
                      child: Text(
                        '•',
                        style: TextStyle(
                          color: const Color(0xFFF0B84D),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF666666),
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
