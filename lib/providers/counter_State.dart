import '../models/favorite.dart';

class PageState {
  final int pageIndex;
  final int id;
  final List<Favorite> favorites;

  PageState({
    required this.pageIndex,
    required this.id,
    required this.favorites,
  });

  PageState copyWith({
    int? pageIndex,
    int? id,
    List<Favorite>? favorites,
  }) {
    return PageState(
      pageIndex: pageIndex ?? this.pageIndex,
      id: id ?? this.id,
      favorites: favorites ?? this.favorites,
    );
  }
}
