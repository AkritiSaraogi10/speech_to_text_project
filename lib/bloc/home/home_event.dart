part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

final class FetchDataEvent extends HomeEvent {}

final class SearchDataEvent extends HomeEvent {
  final String searchText;

  SearchDataEvent({required this.searchText});
}
