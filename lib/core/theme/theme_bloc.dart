import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeLoaded(mode: AppThemeMode.dark)) {
    on<LoadThemeEvent>((event, emit) async {
      final mode = await AppTheme.loadThemeMode();
      emit(ThemeLoaded(mode: mode));
    });

    on<ChangeThemeEvent>((event, emit) async {
      await AppTheme.saveThemeMode(event.mode);
      emit(ThemeLoaded(mode: event.mode));
    });
    
    // Load theme immediately on creation
    add(const LoadThemeEvent());
  }
}

