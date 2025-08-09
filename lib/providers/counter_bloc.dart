import 'package:FlyHigh/models/hotel.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/flight.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';
import '../services/storage_keys.dart';
import 'counter_state.dart';

class CounterBloc extends Cubit<PageState> {
  CounterBloc() : super(PageState(pageIndex: 0, id: 0, favorites: [])) {
    _initFavorites();
  }

  Future<void> _initFavorites() async {
    await _loadFavoritesFromPreferences();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isNotEmpty) {
      await fetchFavoritesFromServer();
    }
  }

  Future<void> _loadFavoritesFromPreferences() async {
    try {
      final String? userKey = await getUserSpecificKey('favorites_state');
      if (userKey == null) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(userKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final loadedFavorites =
        jsonList.map((f) => Favorite.fromJson(f)).toList();
        emit(state.copyWith(favorites: loadedFavorites));
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  Future<void> _saveFavoritesToPreferences() async {
    try {
      final String? userKey = await getUserSpecificKey('favorites_state');
      if (userKey == null) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        userKey,
        jsonEncode(state.favorites.map((f) => f.toJson()).toList()),
      );
    } catch (e) {
      print("Error saving state: $e");
    }
  }

  void updatePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void updateId(int newId) {
    emit(state.copyWith(id: newId));
  }

  Future<void> fetchFavoritesFromServer() async {
    try {
      final favoritesFromApi = await ApiService().getUserFavorites();
      // لازم الـ API يرجع نوع + id
      emit(state.copyWith(favorites: favoritesFromApi));
      await _saveFavoritesToPreferences();
    } catch (e) {
      print("❌ Failed to fetch favorites from API: $e");
    }
  }

  Future<void> toggleFavorite({
    required int itemId,
    required String type,
    Flight? flight,
    Hotel? hotel,
  }) async {
    final currentFavorites = List<Favorite>.from(state.favorites);

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) return;

    try {
      final existingIndex =
      currentFavorites.indexWhere((f) => f.id == itemId && f.type == type);

      if (existingIndex != -1) {
        await ApiService().removeFavorite(favoriteId: itemId, type: type);
        currentFavorites.removeAt(existingIndex);
      } else {
        await ApiService().addFavorite(
          favoriteId: itemId,
          type: type,
          airline: flight?.airline,
          flightNumber: flight?.id,
          from: flight?.from,
          to: flight?.to,
          price: flight?.price,
          departureTime: flight?.departureTime,
          arrivalTime: flight?.arrivalTime,
          date: flight?.date,
        );
        currentFavorites.add(Favorite(id: itemId, type: type));
      }

      emit(state.copyWith(favorites: currentFavorites));
      await _saveFavoritesToPreferences();
    } catch (e) {
      print("❌ Failed to toggle favorite: $e");
    }
  }
}
