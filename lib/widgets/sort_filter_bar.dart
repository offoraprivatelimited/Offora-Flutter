import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SortFilterBar extends StatefulWidget {
  final String currentSortBy;
  final String? selectedCategory;
  final String? selectedCity;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onCityChanged;
  final List<String> availableCities;
  final List<String> availableCategories;

  const SortFilterBar({
    super.key,
    required this.currentSortBy,
    this.selectedCategory,
    this.selectedCity,
    required this.onSortChanged,
    required this.onCategoryChanged,
    required this.onCityChanged,
    required this.availableCities,
    this.availableCategories = const [
      'All Categories',
      'Grocery',
      'Supermarket',
      'Restaurant',
      'Cafe & Bakery',
      'Pharmacy',
      'Electronics',
      'Mobile & Accessories',
      'Fashion & Apparel',
      'Footwear',
      'Jewelry',
      'Home Decor',
      'Furniture',
      'Hardware',
      'Automotive',
      'Books & Stationery',
      'Toys & Games',
      'Sports & Fitness',
      'Beauty & Cosmetics',
      'Salon & Spa',
      'Pet Supplies',
      'Dairy & Produce',
      'Electronics Repair',
      'Optical',
      'Travel & Tours',
      'Department Store',
      'Other',
    ],
  });

  @override
  State<SortFilterBar> createState() => _SortFilterBarState();
}

class _SortFilterBarState extends State<SortFilterBar> {
  late String _selectedCategory;
  late String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'All Categories';
    _selectedCity = widget.selectedCity;
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'discount':
        return 'Highest Discount';
      case 'price':
        return 'Lowest Price';
      case 'newest':
      default:
        return 'Newest First';
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _SortOption(
                    title: 'Newest First',
                    value: 'newest',
                    groupValue: widget.currentSortBy,
                    onChanged: (value) {
                      widget.onSortChanged(value!);
                      Navigator.pop(context);
                    },
                  ),
                  _SortOption(
                    title: 'Highest Discount',
                    value: 'discount',
                    groupValue: widget.currentSortBy,
                    onChanged: (value) {
                      widget.onSortChanged(value!);
                      Navigator.pop(context);
                    },
                  ),
                  _SortOption(
                    title: 'Lowest Price',
                    value: 'price',
                    groupValue: widget.currentSortBy,
                    onChanged: (value) {
                      widget.onSortChanged(value!);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter header
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Category Filter
                    Text(
                      'Business Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableCategories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return FilterChip(
                          label: Text(
                            category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            widget.onCategoryChanged(
                              category == 'All Categories' ? null : category,
                            );
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.brightGold,
                          labelStyle: TextStyle(
                            color:
                                isSelected ? Colors.black87 : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.brightGold
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Location Filter
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        hintText: 'Select Location',
                        labelText: 'Select State/City',
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: AppColors.darkBlue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.darkBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text(
                            'All Locations',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...widget.availableCities.map(
                          (city) => DropdownMenuItem(
                            value: city,
                            child: Text(
                              city,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                        widget.onCityChanged(value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Reset and Apply buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All Categories';
                                _selectedCity = null;
                              });
                              widget.onCategoryChanged(null);
                              widget.onCityChanged(null);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkBlue,
                              side: const BorderSide(
                                color: AppColors.darkBlue,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showFilterOptions,
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkBlue,
                side: const BorderSide(color: AppColors.darkBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showSortOptions,
              icon: const Icon(Icons.sort, size: 18),
              label: Text(_getSortLabel(widget.currentSortBy)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkBlue,
                side: const BorderSide(color: AppColors.darkBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final void Function(String?) onChanged;

  const _SortOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return ListTile(
      onTap: () => onChanged(value),
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.darkBlue : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.darkBlue : Colors.grey.shade400,
            width: 1.4,
          ),
        ),
        child: selected
            ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
