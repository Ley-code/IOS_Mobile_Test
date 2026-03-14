part of 'theme_bloc.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

final class ThemeLoaded extends ThemeState {
  final AppThemeMode mode;

  const ThemeLoaded({required this.mode});

  @override
  List<Object> get props => [mode];
}


