part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

class ChangeThemeEvent extends ThemeEvent {
  final AppThemeMode mode;

  const ChangeThemeEvent({required this.mode});

  @override
  List<Object> get props => [mode];
}


