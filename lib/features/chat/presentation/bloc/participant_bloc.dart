import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/chat/domain/entities/participant_profile.dart';
import 'package:mobile_app/features/chat/domain/usecases/get_participant_profile.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_state.dart';

class ParticipantBloc extends Bloc<ParticipantEvent, ParticipantState> {
  final GetParticipantProfile getParticipantProfile;
  final Map<String, ParticipantProfile> _cache = {};

  ParticipantBloc({required this.getParticipantProfile})
    : super(ParticipantInitial()) {
    on<LoadParticipantProfile>(_onLoadParticipantProfile);
  }

  Future<void> _onLoadParticipantProfile(
    LoadParticipantProfile event,
    Emitter<ParticipantState> emit,
  ) async {
    // Check cache first
    if (_cache.containsKey(event.userId)) {
      emit(ParticipantLoaded(_cache[event.userId]!));
      return;
    }

    emit(ParticipantLoading(event.userId));

    final result = await getParticipantProfile(event.userId);

    result.fold(
      (failure) {
        emit(ParticipantError(event.userId, failure.message));
      },
      (profile) {
        _cache[event.userId] = profile;
        emit(ParticipantLoaded(profile));
      },
    );
  }

  ParticipantProfile? getCachedProfile(String userId) {
    return _cache[userId];
  }
}
