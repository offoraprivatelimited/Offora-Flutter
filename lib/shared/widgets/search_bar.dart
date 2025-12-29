import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTapFilter;

  const AppSearchBar({super.key, this.onChanged, this.onTapFilter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search offers, stores or categories',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onTapFilter,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}
