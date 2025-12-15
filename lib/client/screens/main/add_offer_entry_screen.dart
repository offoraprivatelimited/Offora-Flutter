import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../offers/new_offer_form_screen.dart';
import '../../../services/auth_service.dart';

class AddOfferEntryScreen extends StatelessWidget {
  const AddOfferEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);

    return SafeArea(
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign_outlined,
                    size: 56, color: darkBlue.withAlpha(120)),
                const SizedBox(height: 16),
                Text(
                  'Create a new offer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkBlue,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add images, pricing and details, then submit for review.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    final auth = context.read<AuthService>();
                    final clientId = auth.currentUser?.uid ?? '';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NewOfferFormScreen(
                          clientId: clientId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightGold,
                    foregroundColor: darkBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('New Offer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
