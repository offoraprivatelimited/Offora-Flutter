import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    required this.availableCategories,
  });

  @override
  State<SortFilterBar> createState() => _SortFilterBarState();
}

class _SortFilterBarState extends State<SortFilterBar> {
  late String _selectedCategory;
  late String _selectedCity;
  late String _selectedSortBy;
  List<String> _citySuggestions = [];
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'All Categories';
    _selectedCity = widget.selectedCity ?? '';
    _selectedSortBy = widget.currentSortBy;
    _cityController = TextEditingController(text: widget.selectedCity ?? '');
    _fetchCities();
  }

  @override
  void didUpdateWidget(SortFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected category if it changed from parent
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      setState(() {
        _selectedCategory = widget.selectedCategory ?? 'All Categories';
      });
    }
    // Update city controller if it changed from parent
    if (oldWidget.selectedCity != widget.selectedCity) {
      setState(() {
        _selectedCity = widget.selectedCity ?? '';
        _cityController.text = widget.selectedCity ?? '';
      });
    }
    // Update sort by if it changed from parent
    if (oldWidget.currentSortBy != widget.currentSortBy) {
      setState(() {
        _selectedSortBy = widget.currentSortBy;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchCities() async {
    try {
      final res =
          await Future.delayed(const Duration(milliseconds: 500), () async {
        return await http.post(
          Uri.parse('https://countriesnow.space/api/v0.1/countries/cities'),
          headers: {'Content-Type': 'application/json'},
          body: '{"country": "India"}',
        );
      });
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        final List<dynamic> cities = data['data'] ?? [];
        setState(() {
          _citySuggestions = List<String>.from(cities);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _citySuggestions = [];
        });
      }
    }
  }

  void _showFilterOptions() {
    // Use local state for the bottom sheet
    String tempSortBy = _selectedSortBy;
    String tempCategory = _selectedCategory;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setSheetState) => Container(
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
                        style: Theme.of(builderContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Sort By Section
                      Text(
                        'Sort By',
                        style: Theme.of(builderContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _SortOptionTile(
                        title: 'Newest First',
                        value: 'newest',
                        groupValue: tempSortBy,
                        onChanged: (value) {
                          setSheetState(() {
                            tempSortBy = value!;
                          });
                        },
                      ),
                      _SortOptionTile(
                        title: 'Highest Discount',
                        value: 'discount',
                        groupValue: tempSortBy,
                        onChanged: (value) {
                          setSheetState(() {
                            tempSortBy = value!;
                          });
                        },
                      ),
                      _SortOptionTile(
                        title: 'Lowest Price',
                        value: 'price',
                        groupValue: tempSortBy,
                        onChanged: (value) {
                          setSheetState(() {
                            tempSortBy = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Category Filter
                      Text(
                        'Business Category',
                        style: Theme.of(builderContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.availableCategories.map((category) {
                          final isSelected = tempCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                tempCategory = category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.brightGold
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.brightGold
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black87
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Reset and Apply buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempCategory = 'All Categories';
                                  tempSortBy = 'newest';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.darkBlue,
                                side: const BorderSide(
                                  color: AppColors.darkBlue,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                // Apply changes when closing
                                setState(() {
                                  _selectedSortBy = tempSortBy;
                                  _selectedCategory = tempCategory;
                                });

                                if (tempSortBy != widget.currentSortBy) {
                                  widget.onSortChanged(tempSortBy);
                                }
                                if (tempCategory != widget.selectedCategory) {
                                  widget.onCategoryChanged(
                                    tempCategory == 'All Categories'
                                        ? null
                                        : tempCategory,
                                  );
                                }
                                Navigator.pop(builderContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Filter and Location dropdown buttons (bottom)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _showFilterOptions,
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text(
                      _selectedCategory != 'All Categories'
                          ? 'Filter ($_selectedCategory)'
                          : 'Filter',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      side: const BorderSide(color: AppColors.darkBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 48),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _citySuggestions.where((city) => city
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    fieldViewBuilder: (context, fieldController, focusNode,
                        onFieldSubmitted) {
                      return TextFormField(
                        controller: fieldController,
                        focusNode: focusNode,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Location',
                          hintStyle: const TextStyle(
                            color: AppColors.darkBlue,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city_outlined,
                            color: AppColors.darkBlue,
                            size: 18,
                          ),
                          suffixIcon: _selectedCity.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.darkBlue, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedCity = '';
                                      _cityController.clear();
                                    });
                                    widget.onCityChanged(null);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.darkBlue,
                              width: 1.1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.darkBlue,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          isDense: true,
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _selectedCity = selection;
                        _cityController.text = selection;
                      });
                      widget.onCityChanged(selection);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            color: Colors.white,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    option,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final void Function(String?) onChanged;

  const _SortOptionTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.darkBlue : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.darkBlue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: selected ? AppColors.darkBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
