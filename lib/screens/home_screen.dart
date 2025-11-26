import 'package:flutter/material.dart';
import '../utils/dummy_data.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_banner.dart';
import '../widgets/category_card.dart';
import '../widgets/section_title.dart';
import 'offer_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Offer banner carousel (loads from Firebase)
            OfferBanner(
              imageUrls: const [
                'https://via.placeholder.com/400x180?text=Offer+1',
                'https://via.placeholder.com/400x180?text=Offer+2',
                'https://via.placeholder.com/400x180?text=Offer+3',
                'https://via.placeholder.com/400x180?text=Offer+4',
                'https://via.placeholder.com/400x180?text=Offer+5',
                'https://via.placeholder.com/400x180?text=Offer+6',
              ],
              onTap: () => Navigator.pushNamed(
                context,
                OfferDetailsScreen.routeName,
                arguments: sampleOffers.isNotEmpty ? sampleOffers[0] : null,
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Popular categories'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sampleCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 120,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final cat = sampleCategories[i];
                return CategoryCard(
                  name: cat['name'] as String,
                  icon: Icons.category,
                  onTap: () {},
                );
              },
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Featured stores'),
            const SizedBox(height: 12),
            ...sampleOffers.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OfferCard(
                  offer: o,
                  onTap: () => Navigator.pushNamed(
                    context,
                    OfferDetailsScreen.routeName,
                    arguments: o,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
