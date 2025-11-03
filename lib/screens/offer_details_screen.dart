import 'package:flutter/material.dart';

class OfferDetailsScreen extends StatelessWidget {
  static const String routeName = '/offer';
  const OfferDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final offer =
        args ??
        {
          'title': 'Offer',
          'store': 'Store',
          'image': 'assets/images/offer1.jpg',
          'discount': '10%',
        };

    return Scaffold(
      appBar: AppBar(title: Text(offer['title'] ?? 'Offer')),
      body: ListView(
        children: [
          Image.asset(
            offer['image'] as String,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(height: 220, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(offer['store'] ?? ''),
                    const Spacer(),
                    Chip(label: Text(offer['discount'] ?? '')),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Offer details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a mock offer used for UI preview. Replace with real details from backend.',
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map),
                  label: const Text('Open map preview'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
