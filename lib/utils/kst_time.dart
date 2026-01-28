DateTime nowKst() {
  final utcNow = DateTime.now().toUtc();
  return utcNow.add(const Duration(hours: 9));
}

DateTime todayKst() {
  final now = nowKst();
  return DateTime(now.year, now.month, now.day);
}
