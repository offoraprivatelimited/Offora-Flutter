import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0A1A3A);
    const accentGold = Color(0xFFD4AF37);
    const lightGold = Color(0xFFF8F0E3);
    const mediumGold = Color(0xFFE8D9B0);

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
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
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
              ),

              // Premium Introduction Card
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      lightGold.withOpacity(0.3),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: mediumGold.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withOpacity(0.03),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accentGold.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: accentGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Our Commitment to You',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'At Offora, we are deeply committed to protecting your privacy and personal information. This comprehensive policy explains how we collect, use, and safeguard your data with the highest standards of security and transparency.',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryDark.withOpacity(0.8),
                              height: 1.7,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Policy Sections
              _buildPremiumPolicySection(
                number: '01',
                title: 'Information We Collect',
                icon: Icons.collections_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySubsection(
                      'Personal Information',
                      [
                        'Name, email address, and phone number',
                        'Profile information and user preferences',
                        'Authentication credentials and verification data',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPolicySubsection(
                      'Business Information (Shop Owners)',
                      [
                        'Business name and registration details',
                        'Contact information and operating hours',
                        'Business location and category specifications',
                        'Tax identification numbers (when provided)',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPolicySubsection(
                      'Usage Information',
                      [
                        'Device information and IP address analytics',
                        'App usage patterns and interaction data',
                        'Location data (with explicit permission)',
                        'Saved offers and browsing history insights',
                      ],
                    ),
                  ],
                ),
              ),

              _buildPremiumPolicySection(
                number: '02',
                title: 'How We Use Your Information',
                icon: Icons.settings_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNumberedListItem(
                        'To provide and improve our core services'),
                    const SizedBox(height: 12),
                    _buildNumberedListItem(
                        'To authenticate and verify user identity'),
                    const SizedBox(height: 12),
                    _buildNumberedListItem(
                        'To process and manage offer transactions'),
                    const SizedBox(height: 12),
                    _buildNumberedListItem(
                        'To communicate updates and support'),
                    const SizedBox(height: 12),
                    _buildNumberedListItem(
                        'To personalize your user experience'),
                    const SizedBox(height: 12),
                    _buildNumberedListItem(
                        'To analyze and optimize our Platform'),
                    const SizedBox(height: 12),
                    _buildNumberedListItem('To comply with legal obligations'),
                  ],
                ),
              ),

              _buildPremiumPolicySection(
                number: '03',
                title: 'Information Sharing',
                icon: Icons.share_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We do not sell your personal information. Data sharing occurs only under these specific circumstances:',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryDark.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      'With Shop Owners',
                      'When you interact with their offers for fulfillment purposes',
                      Icons.storefront_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'With Service Providers',
                      'Trusted partners assisting in platform operations',
                      Icons.handshake_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Legal Compliance',
                      'When required by law or to protect legal rights',
                      Icons.gavel_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'With Consent',
                      'Only with your explicit permission',
                      Icons.check_circle_outlined,
                    ),
                  ],
                ),
              ),

              _buildPremiumPolicySection(
                number: '04',
                title: 'Data Security',
                icon: Icons.lock_outlined,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSecurityFeature(
                      'Industry-Standard Encryption',
                      'All data transmission secured with SSL/TLS protocols',
                    ),
                    const SizedBox(height: 16),
                    _buildSecurityFeature(
                      'Firebase Security',
                      'Authentication and Firestore with strict security rules',
                    ),
                    const SizedBox(height: 16),
                    _buildSecurityFeature(
                      'Restricted Access',
                      'Limited to authorized personnel with need-to-know basis',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        'While we implement comprehensive security measures, no method of electronic transmission or storage is 100% secure. We continuously work to maintain the highest security standards.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Rights Section in Grid
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentGold, mediumGold],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '05. Your Rights & Choices',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.5,
                      children: [
                        _buildRightCard(
                          Icons.visibility_outlined,
                          'Access Rights',
                          'Review your personal information anytime',
                          accentGold,
                        ),
                        _buildRightCard(
                          Icons.edit_outlined,
                          'Update Rights',
                          'Modify your information at any time',
                          primaryDark,
                        ),
                        _buildRightCard(
                          Icons.delete_outlined,
                          'Deletion Rights',
                          'Request account and data deletion',
                          accentGold,
                        ),
                        _buildRightCard(
                          Icons.notifications_off_outlined,
                          'Opt-Out Rights',
                          'Control marketing communications',
                          primaryDark,
                        ),
                        _buildRightCard(
                          Icons.import_export_outlined,
                          'Data Portability',
                          'Request a copy of your data',
                          accentGold,
                        ),
                        _buildRightCard(
                          Icons.location_off_outlined,
                          'Location Control',
                          'Manage location services in settings',
                          primaryDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Additional Sections (Brief)
              _buildBriefPolicySection(
                  '06', 'Cookies & Tracking', Icons.cookie_outlined),
              _buildBriefPolicySection(
                  '07', 'Third-Party Services', Icons.extension_outlined),
              _buildBriefPolicySection(
                  '08', 'Children\'s Privacy', Icons.child_care_outlined),
              _buildBriefPolicySection(
                  '09', 'Data Retention', Icons.history_outlined),
              _buildBriefPolicySection(
                  '10', 'International Transfers', Icons.language_outlined),
              _buildBriefPolicySection(
                  '11', 'Policy Updates', Icons.update_outlined),

              // Contact Section
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryDark.withOpacity(0.9),
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
                            Icons.mail_outlined,
                            color: accentGold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          '12. Contact Us',
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
                      'For questions, concerns, or to exercise your privacy rights, please reach out to our dedicated privacy team:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildContactInfo(
                      Icons.email_outlined,
                      'privacy@offora.com',
                      'Email Support',
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      Icons.phone_outlined,
                      '+91 98765 43210',
                      'Phone Support',
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      Icons.location_on_outlined,
                      '123, Business District, Chennai, Tamil Nadu, India - 600001',
                      'Registered Office',
                    ),
                  ],
                ),
              ),

              // Premium Footer
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      lightGold.withOpacity(0.2),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: mediumGold.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: accentGold.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentGold.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_outlined,
                        color: accentGold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We are fully committed to protecting your privacy and maintaining complete transparency about our data practices. Your trust is our highest priority.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryDark.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 2,
                      width: 80,
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

  Widget _buildPremiumPolicySection({
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
                      const Color(0xFFD4AF37).withOpacity(0.1),
                      const Color(0xFFF8F0E3).withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8D9B0).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A1A3A),
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
                          color: const Color(0xFFD4AF37),
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

  Widget _buildPolicySubsection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1A3A),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF0A1A3A).withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildNumberedListItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              size: 14,
              color: Color(0xFFD4AF37),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF0A1A3A).withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
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
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0A1A3A).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0A1A3A).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightCard(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
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

  Widget _buildBriefPolicySection(String number, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1A3A),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A1A3A),
          ),
        ),
        trailing: Icon(
          icon,
          color: const Color(0xFFD4AF37),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFFE8D9B0).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String detail, String label) {
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
            color: const Color(0xFFD4AF37),
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
