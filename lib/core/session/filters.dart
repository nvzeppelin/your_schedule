import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_schedule/core/session.dart';
import 'package:your_schedule/util/logger.dart';

part 'filters.g.dart';

@riverpod
class Filters extends _$Filters {
  late final int _userId;

  @override
  Set<int> build() {
    _userId = ref.watch(selectedSessionProvider.select((value) => value.userData!.id));
    try {
      initializeFromPrefs();
    } catch (e, s) {
      Sentry.captureException(e, stackTrace: s);
      getLogger().e("Error while parsing json", error: e, stackTrace: s);
    }
    return {};
  }

  void add(int id) {
    state = Set.unmodifiable(Set.from(state)..add(id));
    saveToPrefs();
  }

  void addAll(List<int> ids) {
    state = Set.unmodifiable(Set.from(state)..addAll(ids));
    saveToPrefs();
  }

  void remove(int id) {
    state = Set.unmodifiable(Set.from(state)..remove(id));
    saveToPrefs();
  }

  void reset() {
    state = Set.unmodifiable({});
    saveToPrefs();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_userId.filters', jsonEncode(state.toList()));
  }

  Future<void> initializeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final filters = prefs.getString('$_userId.filters');
    if (filters != null) {
      state = Set.unmodifiable(
        (jsonDecode(filters) as List<dynamic>).map((e) => e as int).toSet(),
      );
    }
  }
}
