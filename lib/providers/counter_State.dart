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
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}
