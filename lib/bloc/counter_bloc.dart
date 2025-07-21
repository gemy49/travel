import 'package:bloc/bloc.dart';

import 'counter_State.dart';

class CounterBloc extends Cubit<PageState> {
  CounterBloc() : super(PageState(pageIndex: 0, id: 0));

  void updatePage(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void updateId(int newId) {
    emit(state.copyWith(id: newId));
  }
}
