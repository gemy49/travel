// counter_state.dart
class PageState {
  final int pageIndex;
  final int id;
  final List<int> favoriteIds;

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
      favoriteIds: favoriteIds ?? List.from(this.favoriteIds),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'id': id,
      'favoriteIds': favoriteIds,
    };
  }

  factory PageState.fromJson(Map<String, dynamic> json) {
    return PageState(
      pageIndex: json['pageIndex'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      favoriteIds: List<int>.from(json['favoriteIds'] ?? []),
    );
  }
}
