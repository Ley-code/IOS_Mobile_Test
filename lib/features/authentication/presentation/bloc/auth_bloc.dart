import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';

import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/login_entity.dart';
import 'package:mobile_app/features/authentication/domain/usecases/business_sign_up_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/freelancer_sign_up_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/connect_instagram_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/consume_instagram_session_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/finalize_instagram_session_usecase.dart';
import 'package:mobile_app/features/authentication/domain/entities/instagram_profile.dart';

import '../../domain/usecases/log_in_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogInUsecase logInUsecase;
  final BusinessSignUpUseCase businessSignUpUseCase;
  final FreelancerSignUpUseCase freelancerSignUpUseCase;
  final ConnectInstagramUseCase connectInstagramUseCase;
  final ConsumeInstagramSessionUseCase consumeInstagramSessionUseCase;
  final FinalizeInstagramSessionUseCase finalizeInstagramSessionUseCase;
  final TokenStorage tokenStorage;

  AuthBloc({
    required this.logInUsecase,
    required this.businessSignUpUseCase,
    required this.freelancerSignUpUseCase,
    required this.connectInstagramUseCase,
    required this.consumeInstagramSessionUseCase,
    required this.finalizeInstagramSessionUseCase,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    on<LogInEvent>((event, emit) async {
      emit(AuthLoadingState());

      final result = await logInUsecase(
        LogInParams(logInEntity: event.logInEntity),
      );

      await result.fold(
        (failure) async {
          emit(AuthErrorState(message: failure.message));
        },
        (success) async {
          // After successful login, check for stored session_id and finalize Instagram
          final sessionId = await tokenStorage.getInstagramSessionId();
          if (sessionId != null && sessionId.isNotEmpty) {
            await tokenStorage.clearInstagramSessionId();
            // Finalize Instagram in background - don't block login
            add(FinalizeInstagramSessionEvent(sessionId: sessionId));
          }

          // Check if emit is still valid before emitting
          if (!emit.isDone) {
            emit(
              AuthSignedInState(
                userId: success.user.id,
                userRole: success.user.role,
                userName: success.user.userName,
              ),
            );
          }
        },
      );
    });
    on<BusinessSignUpEvent>((event, emit) async {
      emit(AuthLoadingState());

      final result = await businessSignUpUseCase(
        BusinessSignupParams(businessSignupEntity: event.businessSignupEntity),
      );

      await result.fold(
        (failure) async {
          emit(AuthErrorState(message: failure.message));
        },
        (success) async {
          // After successful signup, check SharedPreferences for session_id
          // and finalize Instagram connection if session_id exists
          final sessionId = await tokenStorage.getInstagramSessionId();
          if (sessionId != null && sessionId.isNotEmpty) {
            // Clear the session_id from storage first
            await tokenStorage.clearInstagramSessionId();
            // Finalize Instagram using the stored session_id
            // Wait for finalize to complete before emitting AuthSignedUpState
            final finalizeResult = await finalizeInstagramSessionUseCase(
              sessionId,
            );
            // Don't block on finalize failure - user can connect Instagram later
            finalizeResult.fold(
              (failure) {
                // Log error but continue with signup
              },
              (_) {
                // Instagram finalized successfully
              },
            );
          }
          // Emit AuthSignedUpState after finalize completes (or if no session)
          // #region agent log
          try {
            print(
              '[DEBUG] BusinessSignUp - Emitting AuthSignedUpState: userId=${success.user.id}, role=${success.user.role}',
            );
          } catch (e) {}
          // #endregion

          // Check if emit is still valid before emitting
          if (!emit.isDone) {
            emit(
              AuthSignedUpState(
                userId: success.user.id,
                userRole: success.user.role,
                userName: success.user.userName,
              ),
            );
          }
        },
      );
    });
    on<FreelancerSignUpEvent>((event, emit) async {
      emit(AuthLoadingState());

      final result = await freelancerSignUpUseCase(
        FreelancerSignupParams(
          freelancerSignupEntity: event.freelancerSignupEntity,
        ),
      );

      await result.fold(
        (failure) async {
          emit(AuthErrorState(message: failure.message));
        },
        (success) async {
          // After successful signup, check SharedPreferences for session_id
          // and finalize Instagram connection if session_id exists
          final sessionId = await tokenStorage.getInstagramSessionId();
          if (sessionId != null && sessionId.isNotEmpty) {
            // Clear the session_id from storage first
            await tokenStorage.clearInstagramSessionId();
            // Finalize Instagram using the stored session_id
            // Wait for finalize to complete before emitting AuthSignedUpState
            final finalizeResult = await finalizeInstagramSessionUseCase(
              sessionId,
            );
            // Don't block on finalize failure - user can connect Instagram later
            finalizeResult.fold(
              (failure) {
                // Log error but continue with signup
              },
              (_) {
                // Instagram finalized successfully
              },
            );
          }
          // Emit AuthSignedUpState after finalize completes (or if no session)
          // #region agent log
          try {
            print(
              '[DEBUG] FreelancerSignUp - Emitting AuthSignedUpState: userId=${success.user.id}, role=${success.user.role}',
            );
          } catch (e) {}
          // #endregion

          // Check if emit is still valid before emitting
          if (!emit.isDone) {
            emit(
              AuthSignedUpState(
                userId: success.user.id,
                userRole: success.user.role,
                userName: success.user.userName,
              ),
            );
          }
        },
      );
    });
    on<LogOutEvent>((event, emit) async {
      await tokenStorage.clearAll();
      emit(AuthLogOutState());
    });
    on<ConnectInstagramEvent>((event, emit) async {
      emit(AuthLoadingState());
      final result = await connectInstagramUseCase(event.code, event.state);
      result.fold(
        (failure) => emit(AuthErrorState(message: failure.message)),
        (success) => emit(InstagramConnectedState()),
      );
    });

    on<ConsumeInstagramSessionEvent>((event, emit) async {
      emit(AuthLoadingState());
      final result = await consumeInstagramSessionUseCase(event.sessionId);
      result.fold(
        (failure) => emit(AuthErrorState(message: failure.message)),
        (profile) => emit(InstagramSessionConsumedState(profile: profile)),
      );
    });

    on<FinalizeInstagramSessionEvent>((event, emit) async {
      emit(AuthLoadingState());
      final result = await finalizeInstagramSessionUseCase(event.sessionId);
      result.fold(
        (failure) => emit(AuthErrorState(message: failure.message)),
        (_) => emit(InstagramSessionFinalizedState()),
      );
    });
  }
}
