String formatModDisplayName(String name) {
  final normalized = name
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final withoutWorkshopId = normalized.replaceFirst(RegExp(r'^\d{6,}\s+'), '');
  final withoutVersion = withoutWorkshopId.replaceFirst(
    RegExp(r'^\d+(?:\.\d+){1,3}\s+'),
    '',
  );
  return withoutVersion.trim().isEmpty ? normalized : withoutVersion.trim();
}
