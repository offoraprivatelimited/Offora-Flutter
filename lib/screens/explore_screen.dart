import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/offer_card.dart';
import '../utils/dummy_data.dart';
import 'offer_details_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppSearchBar(onChanged: (v) {}, onTapFilter: () {}),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: sampleOffers.length,
                itemBuilder: (context, i) {
                  final offer = sampleOffers[i];
                  return OfferCard(
                    offer: offer,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OfferDetailsScreen.routeName,
                      arguments: offer,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
