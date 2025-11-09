import 'package:flutter/material.dart';
import '../utils/dummy_data.dart';
import '../widgets/offer_card.dart';
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
            const SectionTitle(title: 'Trending offers', onViewAll: null),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sampleOffers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final offer = sampleOffers[i];
                  return SizedBox(
                    width: 280,
                    child: OfferCard(
                      offer: offer,
                      onTap: () => Navigator.pushNamed(
                        context,
                        OfferDetailsScreen.routeName,
                        arguments: offer,
                      ),
                    ),
                  );
                },
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
