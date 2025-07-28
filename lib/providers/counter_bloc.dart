// counter_bloc.dart
import 'package:bloc/bloc.dart';
import '../services/storage_keys.dart';
import 'counter_state.dart'; // Adjust import path if needed
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'dart:convert'; // Add this import

class CounterBloc extends Cubit<PageState> {

  CounterBloc() : super(PageState(pageIndex: 0, id: 0, favoriteIds: [])) {
    _loadFavoritesFromPreferences(); // Load user-specific favorites
  }
  Future<void> _loadFavoritesFromPreferences() async {
    try {
      final String? userKey = await getUserSpecificKey('favorites_state');
      if (userKey == null) return; // Handle missing email

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(userKey);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final PageState loadedState = PageState.fromJson(jsonMap);
        // Emit the loaded state, updating the bloc's state
        emit(loadedState);
        print("State loaded from SharedPreferences: $loadedState");
      } else {
        print("No saved state found in SharedPreferences.");
        // The initial state (defined in the constructor) remains
      }
    } catch (e) {
      print("Error loading state from SharedPreferences: $e");
      // Optionally, emit an error state or stick with the initial state
      // emit(state); // Emitting current state is implicit, but you could emit an error state
    }
  }


  Future<void> _saveFavoritesToPreferences() async {
    try {
      final String? userKey = await getUserSpecificKey('favorites_state');
      if (userKey == null) return; // Handle missing email

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(state.toJson());
      await prefs.setString(userKey, jsonString);
      print("User-specific favorites saved: ${state.favoriteIds} for key: $userKey");
    }catch (e) {
      print("Error saving state to SharedPreferences: $e");
      // Optionally, show an error message to the user or log the error more formally
    }
  }
  // --- End persistence logic ---

  void updatePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void updateId(int newId) {
    emit(state.copyWith(id: newId));
  }

  void toggleFavorite(int flightId) {
    // Create a new list based on the current state's favorites
    final List<int> currentFavorites = List<int>.from(state.favoriteIds);
    if (currentFavorites.contains(flightId)) {
      currentFavorites.remove(flightId);
    } else {
      currentFavorites.add(flightId);
    }
    // Emit a new state with the updated favorites list
    emit(state.copyWith(favoriteIds: currentFavorites));
    // Save the updated favorites to local storage
    _saveFavoritesToPreferences();
  }
}