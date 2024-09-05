import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:speech_to_text_project/api/api_repository.dart';
import 'package:speech_to_text_project/model/user_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<FetchDataEvent>(_fetchData);
    on<SearchDataEvent>(_searchDataEvent);
  }

  final ApiRepository _apiRepository = ApiRepository();

  List<User> _allUsers = [];
  FutureOr<void> _fetchData(
      FetchDataEvent event, Emitter<HomeState> emit) async {
    emit(LoadingState());

    try {
      _allUsers = await _apiRepository.fetchUsers();
      emit(LoadedState(user: _allUsers));
    } catch (error) {
      emit(ErrorState(errorMessage: error.toString()));
    }
  }

  FutureOr<void> _searchDataEvent(
      SearchDataEvent event, Emitter<HomeState> emit) {
    try {
      final query = event.searchText.toLowerCase();
      final filteredUsers = _allUsers.where((user) {
        final userName = user.name.toLowerCase();
        final userUsername = user.username.toLowerCase();
        final isMatch =
            userName.contains(query) || userUsername.contains(query);

        return isMatch;
      }).toList();

      emit(LoadedState(user: filteredUsers));
    } catch (error) {
      emit(ErrorState(errorMessage: error.toString()));
    }
  }
}
