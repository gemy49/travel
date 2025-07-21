class PageState {
  final int pageIndex;
  final int id;

  PageState({required this.pageIndex, required this.id});

  PageState copyWith({int? pageIndex, int? id}) {
    return PageState(
      pageIndex: pageIndex ?? this.pageIndex,
      id: id ?? this.id,
    );
  }
}
