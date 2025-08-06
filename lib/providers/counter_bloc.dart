// counter_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/flight.dart';
import '../services/api_service.dart';
import '../services/storage_keys.dart';
import 'counter_state.dart';

class CounterBloc extends Cubit<PageState> {
  CounterBloc() : super(PageState(pageIndex: 0, id: 0, favoriteIds: [])) {
    _initFavorites();
  }

  /// أول ما البلوق يتبني نقرأ المفضلة
  Future<void> _initFavorites() async {
    await _loadFavoritesFromPreferences();

    // نقرأ الإيميل
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    // لو فيه إيميل يبقى اليوزر عامل لوج إن → نجيب المفضلة من السيرفر
    if (email.isNotEmpty) {
      await fetchFavoritesFromServer();
    }
  }

  /// تحميل المفضلة من التخزين المحلي
  Future<void> _loadFavoritesFromPreferences() async {
    try {
      final String? userKey = await getUserSpecificKey('favorites_state');
      if (userKey == null) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(userKey);

      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final List<int> loadedFavorites = List<int>.from(jsonMap['favoriteIds'] ?? []);
        emit(state.copyWith(favoriteIds: loadedFavorites));
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  /// حفظ المفضلة محلي
  Future<void> _saveFavoritesToPreferences() async {
    try {
      final String? userKey = await getUserSpecificKey('favorites_state');
      if (userKey == null) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        userKey,
        jsonEncode({
          'favoriteIds': state.favoriteIds,
        }),
      );
    } catch (e) {
      print("Error saving state: $e");
    }
  }

  /// تحديث الصفحة
  void updatePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  /// تحديث الـ ID
  void updateId(int newId) {
    emit(state.copyWith(id: newId));
  }

  /// جلب المفضلة من السيرفر
  Future<void> fetchFavoritesFromServer() async {
    try {
      final favorites = await ApiService().getUserFavorites();
      final favoriteIdsFromApi = favorites.map((f) => f.id).toList();

      emit(state.copyWith(favoriteIds: favoriteIdsFromApi));
      await _saveFavoritesToPreferences();
    } catch (e) {
      print("❌ Failed to fetch favorites from API: $e");
    }
  }

  /// إضافة أو إزالة مفضلة
  Future<void> toggleFavorite(int flightId, Flight flight) async {
    final List<int> currentFavorites = List<int>.from(state.favoriteIds);

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) return;

    try {
      if (currentFavorites.contains(flightId)) {
        // إزالة من المفضلة
        await ApiService().removeFavorite(
          favoriteId: flightId,
          type: "flight",
        );
        currentFavorites.remove(flightId);
      } else {
        // إضافة للمفضلة
        await ApiService().addFavorite(
          favoriteId: flightId,
          type: "flight",
          airline: flight.airline,
          flightNumber: flight.id,
          from: flight.from,
          to: flight.to,
          price: flight.price,
          departureTime: flight.departureTime,
          arrivalTime: flight.arrivalTime,
          date: flight.date,
        );
        currentFavorites.add(flightId);
      }

      emit(state.copyWith(favoriteIds: currentFavorites));
      await _saveFavoritesToPreferences();
    } catch (e) {
      print("❌ Failed to toggle favorite: $e");
    }
  }
}
