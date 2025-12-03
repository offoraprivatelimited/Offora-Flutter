import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brightGold.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/logo/original/Logo_without_text_with_background.jpg',
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Offora',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Gateway to Local Deals and Savings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: brightGold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Our Mission',
            'Offora is dedicated to connecting local businesses with customers through exclusive offers and deals. We empower shop owners to reach more customers while helping users discover amazing savings in their area.',
          ),
          const SizedBox(height: 20),
          _buildSection(
            'What We Do',
            'We provide a platform where:\n\n• Shop owners can create and manage exclusive offers\n• Users can browse, compare, and save on local deals\n• Communities thrive through local commerce\n• Businesses grow through increased visibility',
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Why Choose Offora?',
            '✓ Verified local businesses\n✓ Real-time offer updates\n✓ Easy-to-use interface\n✓ Exclusive deals you won\'t find elsewhere\n✓ Support your local community',
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Our Vision',
            'We envision a future where every local business can compete in the digital marketplace, and every customer can find the best deals right in their neighborhood. Together, we\'re building stronger local economies, one offer at a time.',
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Thank you for being part of the Offora community!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F477D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
