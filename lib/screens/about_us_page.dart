import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0A1A3A);
    const accentGold = Color(0xFFD4AF37);
    const lightGold = Color(0xFFF8F0E3);
    const mediumGold = Color(0xFFE8D9B0);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600 ? 80 : 24,
          vertical: 60,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              'About Us',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryDark,
                letterSpacing: -0.4,
              ),
            ),
          ),

          // Mission Section with Premium Card
          _buildPremiumSection(
            icon: Icons.flag_outlined,
            title: 'Our Mission',
            content:
                'Offora is dedicated to connecting local businesses with customers through exclusive offers and deals. We empower shop owners to reach more customers while helping users discover amazing savings in their area.',
            gradientColors: [const Color(0xFFF8F0E3), const Color(0xFFFCF8F3)],
            borderColor: mediumGold,
          ),
          const SizedBox(height: 40),

          // What We Do Section with Features Grid
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: const Text(
              'What We Do',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: primaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Text(
            'We provide a platform where innovation meets opportunity, creating value for both businesses and customers alike.',
            style: TextStyle(
              fontSize: 15,
              color: primaryDark.withOpacity(0.7),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            // Slightly taller cards to avoid vertical overflow on narrow widths
            childAspectRatio: 3.2,
            children: [
              _buildFeatureCard(
                Icons.storefront_outlined,
                'Business Empowerment',
                'Shop owners create and manage exclusive offers',
                accentGold,
              ),
              _buildFeatureCard(
                Icons.search_outlined,
                'Deal Discovery',
                'Users browse, compare, and save on local deals',
                primaryDark,
              ),
              _buildFeatureCard(
                Icons.people_outlined,
                'Community Building',
                'Thriving ecosystems through local commerce',
                accentGold,
              ),
              _buildFeatureCard(
                Icons.trending_up_outlined,
                'Growth Acceleration',
                'Increased visibility and business expansion',
                primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Why Choose Us Section with Check List
          _buildPremiumSection(
            icon: Icons.star_outline,
            title: 'Why Choose Offora?',
            content:
                'Experience the difference with our premium platform designed for maximum value and exceptional service.',
            gradientColors: [Colors.white, const Color(0xFFF8F8F8)],
            borderColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: lightGold.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildPremiumListItem(
                  'Verified Local Businesses',
                  'Only authentic, quality establishments',
                  Icons.verified_outlined,
                  accentGold,
                ),
                const SizedBox(height: 16),
                _buildPremiumListItem(
                  'Real-time Offer Updates',
                  'Instant notifications on new deals',
                  Icons.update_outlined,
                  primaryDark,
                ),
                const SizedBox(height: 16),
                _buildPremiumListItem(
                  'Intuitive User Interface',
                  'Seamless navigation and discovery',
                  Icons.phone_iphone_outlined,
                  accentGold,
                ),
                const SizedBox(height: 16),
                _buildPremiumListItem(
                  'Exclusive Local Deals',
                  'Unbeatable savings you won\'t find elsewhere',
                  Icons.lock_outlined,
                  primaryDark,
                ),
                const SizedBox(height: 16),
                _buildPremiumListItem(
                  'Community Impact',
                  'Direct support for local economies',
                  Icons.favorite_outline,
                  accentGold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Vision Section
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: lightGold.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Vision',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'To be the leading platform for local commerce, fostering growth and innovation in communities worldwide.',
                  style: TextStyle(
                    fontSize: 15,
                    color: primaryDark.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection({
    required IconData icon,
    required String title,
    required String content,
    required List<Color> gradientColors,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF0A1A3A).withOpacity(0.8),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1A3A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF0A1A3A).withOpacity(0.6),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumListItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
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
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0A1A3A).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle_outlined,
          color: Color(0xFFD4AF37),
          size: 20,
        ),
      ],
    );
  }
}
