import 'package:bloc/bloc.dart';
import 'counter_State.dart';

class CounterBloc extends Cubit<PageState> {
  CounterBloc() : super(PageState(pageIndex: 0, id: 0, favoriteIds: []));

  void updatePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void updateId(int newId) {
    emit(state.copyWith(id: newId));
  }

  void toggleFavorite(int flightId) {
    final updatedFavorites = List<int>.from(state.favoriteIds);
    if (updatedFavorites.contains(flightId)) {
      updatedFavorites.remove(flightId);
    } else {
      updatedFavorites.add(flightId); //
    }
    emit(state.copyWith(favoriteIds: updatedFavorites));
  }
}
