class ActiveModOrderService {
  const ActiveModOrderService();

  List<String> enableSelected({
    required List<String> activeIds,
    required Iterable<String> selectedAvailable,
  }) {
    final next = [...activeIds];
    for (final id in selectedAvailable) {
      if (!next.contains(id)) next.add(id);
    }
    return next;
  }

  List<String> disableSelected({
    required List<String> activeIds,
    required Set<String> selectedActive,
  }) {
    return activeIds.where((id) => !selectedActive.contains(id)).toList();
  }

  List<String> moveSelected({
    required List<String> activeIds,
    required Set<String> selectedActive,
    required int delta,
  }) {
    final next = [...activeIds];
    if (selectedActive.isEmpty) return next;
    if (delta < 0) {
      for (var i = 1; i < next.length; i++) {
        if (selectedActive.contains(next[i]) &&
            !selectedActive.contains(next[i - 1])) {
          final temp = next[i - 1];
          next[i - 1] = next[i];
          next[i] = temp;
        }
      }
    } else {
      for (var i = next.length - 2; i >= 0; i--) {
        if (selectedActive.contains(next[i]) &&
            !selectedActive.contains(next[i + 1])) {
          final temp = next[i + 1];
          next[i + 1] = next[i];
          next[i] = temp;
        }
      }
    }
    return next;
  }

  List<String> moveSelectedToEdge({
    required List<String> activeIds,
    required Set<String> selectedActive,
    required bool bottom,
  }) {
    if (selectedActive.isEmpty) return [...activeIds];
    final selected = activeIds.where(selectedActive.contains).toList();
    final rest = activeIds.where((id) => !selectedActive.contains(id)).toList();
    return bottom ? [...rest, ...selected] : [...selected, ...rest];
  }

  List<String> reorder({
    required List<String> activeIds,
    required int oldIndex,
    required int newIndex,
  }) {
    final next = [...activeIds];
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    final id = next.removeAt(oldIndex);
    next.insert(target, id);
    return next;
  }
}
