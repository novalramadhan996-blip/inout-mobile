import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/models/dropdown_item.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';

class AppInputDropdown extends StatefulWidget {
  const AppInputDropdown({
    super.key,
    required this.controller,
    required this.hintText,
    required this.items,
    this.label = '',
    this.onChanged,
    this.onMultipleChanged,
    this.selectedValues = const [],
    this.multiple = false,
    this.validator,
    this.isRequired = false,
    this.isLoading = false,
    this.onSearchChanged,
    this.filterFn,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  final TextEditingController controller;
  final String hintText;
  final String label;

  final List<DropdownItem> items;

  final bool multiple;
  final List<String> selectedValues;

  final ValueChanged<String?>? onChanged;
  final ValueChanged<List<String>>? onMultipleChanged;

  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isLoading;
  final ValueChanged<String>? onSearchChanged;
  final bool Function(DropdownItem, String)? filterFn;
  final Duration debounceDuration;

  @override
  State<AppInputDropdown> createState() => _AppInputDropdownState();
}

class _AppInputDropdownState extends State<AppInputDropdown> {
  late List<String> _selectedValues;
  Timer? _debounce;
  TextEditingController? _searchController;
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _selectedValues = [...widget.selectedValues];
    _updateController();
    _isLoadingNotifier.value = widget.isLoading;
  }

  @override
  void didUpdateWidget(AppInputDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isLoadingNotifier.value = widget.isLoading;
  }

  void _updateController() {
    final selectedLabels = widget.items
        .where((item) => _selectedValues.contains(item.value))
        .map((item) => item.label)
        .toList();
    widget.controller.text = selectedLabels.join(', ');
  }

  void _onSearchInput(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearchChanged?.call(value);
    });
  }

  List<DropdownItem> _getFilteredItems(List<DropdownItem> items, String query) {
    if (query.isEmpty) return items;
    if (widget.filterFn != null) {
      return items.where((item) => widget.filterFn!(item, query)).toList();
    }
    return items
        .where((item) => item.label.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController?.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _showSingleSelect() async {
    _searchController?.dispose();
    _searchController = TextEditingController();
    widget.onSearchChanged?.call('');
    final result = await showModalBottomSheet<DropdownItem>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return _SearchableSheet(
          searchController: _searchController!,
          hintText: widget.hintText,
          getItems: () => widget.items,
          isLoadingNotifier: _isLoadingNotifier,
          onSearchInput: widget.onSearchChanged != null ? _onSearchInput : null,
          getFilteredItems: _getFilteredItems,
          multiple: false,
          selectedValues: _selectedValues,
        );
      },
    );

    if (result != null) {
      widget.controller.text = result.label;
      widget.onChanged?.call(result.value);
    }
  }

  Future<void> _showMultiSelect() async {
    _searchController?.dispose();
    _searchController = TextEditingController();
    final temp = [..._selectedValues];

    final result =
        await showModalBottomSheet<List<String>>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return _SearchableSheet(
              searchController: _searchController!,
              hintText: widget.hintText,
              getItems: () => widget.items,
              isLoadingNotifier: _isLoadingNotifier,
              onSearchInput: widget.onSearchChanged != null
                  ? _onSearchInput
                  : null,
              getFilteredItems: _getFilteredItems,
              multiple: true,
              selectedValues: temp,
            );
          },
        ).whenComplete(() {
          widget.onSearchChanged?.call('');
          _searchController?.clear();
        });

    if (result != null) {
      setState(() {
        _selectedValues = result;
        _updateController();
      });
      widget.onMultipleChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty)
            AppLabel(label: widget.label, isRequired: widget.isRequired),

          if (!widget.multiple)
            TextFormField(
              controller: widget.controller,
              readOnly: true,
              onTap: _showSingleSelect,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: AppColors.whiteColor,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            TextFormField(
              controller: widget.controller,
              readOnly: true,
              onTap: _showMultiSelect,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: AppColors.whiteColor,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchableSheet extends StatefulWidget {
  const _SearchableSheet({
    required this.searchController,
    required this.hintText,
    required this.getItems,
    required this.isLoadingNotifier,
    required this.onSearchInput,
    required this.getFilteredItems,
    required this.multiple,
    required this.selectedValues,
  });

  final TextEditingController searchController;
  final String hintText;
  final List<DropdownItem> Function() getItems;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueChanged<String>? onSearchInput;
  final List<DropdownItem> Function(List<DropdownItem>, String)
  getFilteredItems;
  final bool multiple;
  final List<String> selectedValues;

  @override
  State<_SearchableSheet> createState() => _SearchableSheetState();
}

class _SearchableSheetState extends State<_SearchableSheet> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.isLoadingNotifier.addListener(_onLoadingChanged);
  }

  @override
  void didUpdateWidget(_SearchableSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoadingNotifier != widget.isLoadingNotifier) {
      oldWidget.isLoadingNotifier.removeListener(_onLoadingChanged);
      widget.isLoadingNotifier.addListener(_onLoadingChanged);
    }
  }

  @override
  void dispose() {
    widget.isLoadingNotifier.removeListener(_onLoadingChanged);
    super.dispose();
  }

  void _onLoadingChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.getItems();
    final filtered = widget.getFilteredItems(items, _query);
    final isLoading = widget.isLoadingNotifier.value;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: widget.searchController,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: AppColors.greyCard,
                  hintStyle: const TextStyle(color: AppColors.secondaryColor),
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.secondaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _query = value);
                  widget.onSearchInput?.call(value);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada data ditemukan',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final item = filtered[index];
                        if (widget.multiple) {
                          final isSelected = widget.selectedValues.contains(
                            item.value,
                          );
                          return ListTile(
                            tileColor: isSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : null,
                            title: Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              if (isSelected) {
                                widget.selectedValues.remove(item.value);
                              } else {
                                widget.selectedValues.add(item.value);
                              }
                              Navigator.pop(
                                context,
                                List<String>.from(widget.selectedValues),
                              );
                            },
                          );
                        }
                        return ListTile(
                          title: Text(
                            item.label,
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
