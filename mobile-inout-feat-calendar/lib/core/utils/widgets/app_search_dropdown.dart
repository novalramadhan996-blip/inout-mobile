import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';

class AppSearchDropdown<T> extends StatefulWidget {
  const AppSearchDropdown({
    super.key,
    required this.controller,
    required this.hintText,
    required this.items,
    required this.itemBuilder,
    this.label = '',
    this.onSelected,
    this.onSearchChanged,
    this.filterFn,
    this.validator,
    this.isRequired = false,
    this.isLoading = false,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  final TextEditingController controller;
  final String hintText;
  final String label;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T?>? onSelected;
  final ValueChanged<String>? onSearchChanged;
  final bool Function(T, String)? filterFn;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool isLoading;
  final Duration debounceDuration;

  @override
  State<AppSearchDropdown<T>> createState() => _AppSearchDropdownState<T>();
}

class _AppSearchDropdownState<T> extends State<AppSearchDropdown<T>> {
  Timer? _debounce;
  TextEditingController? _searchController;
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _isLoadingNotifier.value = widget.isLoading;
  }

  @override
  void didUpdateWidget(AppSearchDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isLoadingNotifier.value = widget.isLoading;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController?.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  void _onSearchInput(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearchChanged?.call(value);
    });
  }

  List<T> _getFilteredItems(List<T> items, String query) {
    if (query.isEmpty) return items;
    if (widget.filterFn != null) {
      return items.where((item) => widget.filterFn!(item, query)).toList();
    }
    return items
        .where(
          (item) => widget
              .itemBuilder(item)
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> _openSearchSheet() async {
    _searchController?.dispose();
    _searchController = TextEditingController();
    final result =
        await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return _SearchSheet<T>(
              searchController: _searchController!,
              hintText: widget.hintText,
              getItems: () => widget.items,
              itemBuilder: widget.itemBuilder,
              isLoadingNotifier: _isLoadingNotifier,
              onSearchInput: widget.onSearchChanged != null
                  ? _onSearchInput
                  : null,
              getFilteredItems: _getFilteredItems,
            );
          },
        ).whenComplete(() {
          widget.onSearchChanged?.call('');
          _searchController?.clear();
        });

    if (result != null) {
      widget.controller.text = widget.itemBuilder(result);
      widget.onSelected?.call(result);
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
          TextFormField(
            controller: widget.controller,
            readOnly: true,
            onTap: _openSearchSheet,
            validator: widget.validator,
            style: const TextStyle(
              color: AppColors.blackColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: AppColors.whiteColor,
              hintStyle: const TextStyle(color: AppColors.secondaryColor),
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          widget.controller.clear();
                        });
                        widget.onSelected?.call(null);
                      },
                    )
                  : const Icon(Icons.search, color: AppColors.secondaryColor),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.redColors),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  const _SearchSheet({
    required this.searchController,
    required this.hintText,
    required this.getItems,
    required this.itemBuilder,
    required this.isLoadingNotifier,
    required this.onSearchInput,
    required this.getFilteredItems,
  });

  final TextEditingController searchController;
  final String hintText;
  final List<T> Function() getItems;
  final String Function(T) itemBuilder;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueChanged<String>? onSearchInput;
  final List<T> Function(List<T>, String) getFilteredItems;

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.isLoadingNotifier.addListener(_onLoadingChanged);
  }

  @override
  void didUpdateWidget(_SearchSheet<T> oldWidget) {
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
                        return ListTile(
                          title: Text(
                            widget.itemBuilder(item),
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
