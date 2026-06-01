import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class AppCubit<State> {
  AppCubit(this._state);

  final StreamController<State> _controller =
      StreamController<State>.broadcast();
  State _state;

  State get state => _state;
  Stream<State> get stream => _controller.stream;

  void emit(State state) {
    if (_state == state) return;
    _state = state;
    if (!_controller.isClosed) {
      _controller.add(_state);
    }
  }

  Future<void> close() async {
    await _controller.close();
  }
}


class ViewStateCubit extends AppCubit<int> {
  ViewStateCubit() : super(0);

  void refresh() {
    emit(state + 1);
  }

  void update(VoidCallback changes) {
    changes();
    refresh();
  }
}

mixin CubitStateMixin<T extends StatefulWidget> on State<T> {
  final ViewStateCubit viewCubit = ViewStateCubit();

  void refreshView() {
    viewCubit.refresh();
  }

  void updateView(VoidCallback changes) {
    viewCubit.update(changes);
  }

  Widget buildCubitView(Widget Function(BuildContext context) builder) {
    return AppCubitBuilder<ViewStateCubit, int>(
      cubit: viewCubit,
      builder: (context, _) => builder(context),
    );
  }

  @override
  void dispose() {
    viewCubit.close();
    super.dispose();
  }
}

class AppCubitBuilder<Cubit extends AppCubit<State>, State>
    extends StatelessWidget {
  const AppCubitBuilder({
    super.key,
    required this.cubit,
    required this.builder,
  });

  final Cubit cubit;
  final Widget Function(BuildContext context, State state) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<State>(
      stream: cubit.stream,
      initialData: cubit.state,
      builder: (context, snapshot) {
        return builder(context, snapshot.data as State);
      },
    );
  }
}
