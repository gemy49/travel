// counter_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/flight.dart';
import '../services/api_service.dart';
import '../services/storage_keys.dart';
import 'counter_state.dart';

class CounterBloc extends Cubit<PageState> {
  CounterBloc()
      : super(PageState(pageIndex: 0, id: 0, favoriteIds: [])) {
    _loadFavoritesFromPreferences();
  }

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

  void updatePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void updateId(int newId) {
    emit(state.copyWith(id: newId));
  }

  Future<void> toggleFavorite(int flightId,Flight flight) async {
    final List<int> currentFavorites = List<int>.from(state.favoriteIds);

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) return;

    try {
      if (currentFavorites.contains(flightId)) {
        await ApiService().removeFavorite(
          favoriteId: flightId.toString(),
          type: "flight",
        );
        currentFavorites.remove(flightId);
      } else {
        await ApiService().addFavorite(
          favoriteId: flightId.toString(),
          type: "flight",
          airline: flight.airline,
          flightNumber: flight.id,
          from: flight.from,
          to: flight.to,
          price:  flight.price,
          departureTime:flight.departureTime,
          arrivalTime: flight.arrivalTime,
          date: flight.date,

        );
        currentFavorites.add(flightId);
      }

      emit(state.copyWith(favoriteIds: currentFavorites));
      _saveFavoritesToPreferences();
    } catch (e) {
      print("❌ Failed to toggle favorite: $e");
    }
  }
}
