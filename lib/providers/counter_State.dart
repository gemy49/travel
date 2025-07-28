// counter_state.dart
import 'dart:convert'; // Add this import for jsonEncode/jsonDecode

class PageState {
  final int pageIndex;
  final int id;
  final List<int> favoriteIds; // Consider using Set<int> internally for efficiency if needed

  PageState({
    required this.pageIndex,
    required this.id,
    required this.favoriteIds,
  });

  PageState copyWith({
    int? pageIndex,
    int? id,
    List<int>? favoriteIds,
  }) {
    return PageState(
      pageIndex: pageIndex ?? this.pageIndex,
      id: id ?? this.id,
      // Create a new list to ensure immutability
      favoriteIds: favoriteIds ?? List.from(this.favoriteIds),
    );
  }

  // --- Add methods for serialization ---
  // Convert the entire state or just the part we want to persist (favoriteIds) to a Map
  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'id': id,
      'favoriteIds': favoriteIds, // List is directly serializable by jsonEncode
    };
  }

  // Create a PageState from a Map (loaded from SharedPreferences)
  factory PageState.fromJson(Map<String, dynamic> json) {
    return PageState(
      pageIndex: json['pageIndex'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      favoriteIds: List<int>.from(json['favoriteIds'] as List? ?? []),
    );
  }
// --- End serialization methods ---
}