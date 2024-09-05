part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeBuildState extends HomeState {}

final class HomeActionState extends HomeState {}

final class LoadingState extends HomeBuildState {}

final class LoadedState extends HomeBuildState {
  final List<User> user;
  LoadedState({required this.user});
}

final class ErrorState extends HomeBuildState {
  final String errorMessage;
  ErrorState({required this.errorMessage});
}
