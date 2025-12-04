import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  static const primaryDark = Color(0xFF0A1A3A);
  static const accentGold = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF8F0E3);
  static const mediumGold = Color(0xFFE8D9B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              lightGold.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 80 : 24,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentGold, mediumGold],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LEGAL DOCUMENT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                  color: primaryDark.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: accentGold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryDark,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.update_outlined,
                          size: 16,
                          color: primaryDark.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last Updated: December 4, 2025',
                          style: TextStyle(
                            fontSize: 15,
                            color: primaryDark.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Acceptance Banner
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentGold.withOpacity(0.1),
                      accentGold.withOpacity(0.05),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accentGold.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentGold.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentGold.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.gavel_outlined,
                        color: accentGold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Acceptance of Terms',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'By accessing or using the Offora platform ("Platform"), you agree to be bound by these comprehensive Terms and Conditions. If you do not agree to these terms, please refrain from using the Platform.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryDark.withOpacity(0.8),
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 2,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentGold, mediumGold],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),

              // Terms Sections
              _buildTermSection(
                number: '01',
                title: 'Definitions',
                icon: Icons.article_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDefinitionCard(
                      'Platform',
                      'The Offora mobile and web application ecosystem',
                      Icons.apps_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDefinitionCard(
                      'User',
                      'Any individual browsing and utilizing offers',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildDefinitionCard(
                      'Shop Owner',
                      'Businesses creating and managing offers',
                      Icons.storefront_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDefinitionCard(
                      'Offer',
                      'Promotional deals posted by Shop Owners',
                      Icons.local_offer_outlined,
                    ),
                  ],
                ),
              ),

              // User Accounts Grid
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      '02',
                      'User Accounts',
                      Icons.person_add_outlined,
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 3,
                      children: [
                        _buildTermCard(
                          'Age Requirement',
                          'You must be at least 18 years old to create an account',
                          Icons.eighteen_mp_outlined,
                        ),
                        _buildTermCard(
                          'Credential Security',
                          'Maintain confidentiality of your account credentials',
                          Icons.lock_outlined,
                        ),
                        _buildTermCard(
                          'Information Accuracy',
                          'Provide accurate, current, and complete registration details',
                          Icons.verified_outlined,
                        ),
                        _buildTermCard(
                          'Account Responsibility',
                          'You are responsible for all activities under your account',
                          Icons.security_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shop Owner Responsibilities
              _buildTermSection(
                number: '03',
                title: 'Shop Owner Responsibilities',
                icon: Icons.business_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResponsibilityItem(
                      'Provide accurate business information and valid documentation',
                      'Accuracy',
                    ),
                    const SizedBox(height: 16),
                    _buildResponsibilityItem(
                      'All offers must comply with applicable laws and regulations',
                      'Compliance',
                    ),
                    const SizedBox(height: 16),
                    _buildResponsibilityItem(
                      'Honor all offers posted on the Platform as presented',
                      'Honor System',
                    ),
                    const SizedBox(height: 16),
                    _buildResponsibilityItem(
                      'Avoid posting misleading, fraudulent, or deceptive offers',
                      'Transparency',
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryDark.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accentGold.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Offora reserves the right to approve, reject, or remove any offer at our discretion.',
                              style: TextStyle(
                                fontSize: 15,
                                color: primaryDark.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // User Conduct Grid
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      '04',
                      'User Conduct',
                      Icons.rule_outlined,
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.5,
                      children: [
                        _buildConductCard(
                          Icons.block_outlined,
                          'No Misuse',
                          'Do not misuse the Platform or use it for illegal purposes',
                          Colors.red,
                        ),
                        _buildConductCard(
                          Icons.security_outlined,
                          'No Manipulation',
                          'Do not attempt to manipulate, hack, or disrupt the Platform',
                          Colors.orange,
                        ),
                        _buildConductCard(
                          Icons.copyright_outlined,
                          'Respect IP Rights',
                          'Respect the intellectual property rights of others',
                          Colors.blue,
                        ),
                        _buildConductCard(
                          Icons.do_not_disturb_outlined,
                          'No Harassment',
                          'Harassment, abusive behavior, or spam is strictly prohibited',
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Key Terms Sections
              _buildTermSection(
                number: '05',
                title: 'Offers and Transactions',
                icon: Icons.shopping_bag_outlined,
                content: _buildKeyPoints([
                  'All offers are subject to availability and may change without notice',
                  'Offora acts as a platform connecting Users and Shop Owners',
                  'Users should verify offer details directly with Shop Owners',
                  'Offora is not responsible for disputes between parties',
                ]),
              ),

              _buildTermSection(
                number: '06',
                title: 'Intellectual Property',
                icon: Icons.copyright_outlined,
                content: _buildKeyPoints([
                  'All Platform content is owned by Offora or its licensors',
                  'Users may not copy, reproduce, or distribute without permission',
                  'Shop Owners grant Offora a license to display their content',
                ]),
              ),

              // Disclaimer & Liability
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.orange.withOpacity(0.05)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_outlined,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            '07. Disclaimer & Liability',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: primaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disclaimer of Warranties',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildWarningPoint(
                              'Platform provided "as is" without warranties'),
                          _buildWarningPoint(
                              'No guarantee of accuracy, reliability, or availability'),
                          _buildWarningPoint(
                              'No guarantee that offers will be honored'),
                          _buildWarningPoint(
                              'Use of Platform is at your own risk'),
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Limitation of Liability',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildWarningPoint(
                              'No liability for indirect or consequential damages'),
                          _buildWarningPoint(
                              'Total liability limited to last 12 months payment'),
                          _buildWarningPoint(
                              'Not responsible for third-party content or services'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Privacy, Termination & More
              _buildTermSection(
                number: '08',
                title: 'Privacy',
                icon: Icons.privacy_tip_outlined,
                content: Text(
                  'Your use of the Platform is subject to our comprehensive Privacy Policy, which is fully incorporated into these Terms by reference.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryDark.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
              ),

              // Contact Section
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryDark.withOpacity(0.95),
                      primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accentGold.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.contact_support_outlined,
                            color: accentGold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          'Legal Contact',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'For questions about these Terms and Conditions, please contact our legal team:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLegalContactInfo(
                      Icons.email_outlined,
                      'legal@offora.com',
                      'Legal Email',
                    ),
                    const SizedBox(height: 16),
                    _buildLegalContactInfo(
                      Icons.phone_outlined,
                      '+91 98765 43210',
                      'Legal Phone',
                    ),
                    const SizedBox(height: 16),
                    _buildLegalContactInfo(
                      Icons.location_on_outlined,
                      '123, Business District, Chennai, Tamil Nadu, India - 600001',
                      'Registered Office',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 1,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentGold, accentGold.withOpacity(0)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Final Agreement Banner
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      lightGold.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accentGold,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: accentGold.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.handshake_outlined,
                        color: accentGold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Agreement Confirmation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'By using Offora, you acknowledge that you have read, understood, and agree to be bound by these comprehensive Terms and Conditions. Your continued use constitutes ongoing acceptance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryDark.withOpacity(0.8),
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 2,
                      width: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentGold, mediumGold],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String number,
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentGold.withOpacity(0.1),
                      mediumGold.withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: mediumGold.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: accentGold,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A1A3A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    content,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionCard(String term, String definition, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8D9B0).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A1A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  definition,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0A1A3A).withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentGold, mediumGold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
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
              Row(
                children: [
                  Icon(
                    icon,
                    color: accentGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8D9B0).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: accentGold,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1A3A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0A1A3A).withOpacity(0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilityItem(String text, String tag) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8D9B0).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentGold.withOpacity(0.3),
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accentGold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF0A1A3A).withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConductCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1A3A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0A1A3A).withOpacity(0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points
          .map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF0A1A3A).withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF0A1A3A).withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalContactInfo(IconData icon, String detail, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accentGold,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
