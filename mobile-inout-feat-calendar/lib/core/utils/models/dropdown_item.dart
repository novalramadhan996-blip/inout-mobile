class DropdownItem {
  final String label;
  final String value;
  final dynamic item;

  const DropdownItem({required this.label, required this.value, this.item});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
